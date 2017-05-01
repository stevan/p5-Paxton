package Paxton::Streaming::IO::Writer;
# ABSTRACT: Convert a stream of tokens into a JSON string
use Moxie;

use Carp         ();
use Scalar::Util ();

use IO::Handle;
use IO::Scalar;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_WRITER_DEBUG} // 0;

# ...

extends 'Moxie::Object';
   with 'Paxton::Streaming::API::Consumer';

has 'sink'    => sub { die 'You must specify a `sink` to write to.'};
has 'context' => sub { Paxton::Core::Context->new };

# private ...
has '_needs_comma'  => sub { 0 };
has '_pretty_print' => sub { 0 };

## Constructors

sub new_to_handle ($class, $handle) {
    (Scalar::Util::blessed( $handle ) && $handle->isa('IO::Handle') )
        || throw('The stream must be derived from IO::Handle' );

    $class->new( sink => $handle );
}

sub new_to_string ($class, $string_ref) {
    (defined $string_ref && ref $string_ref eq 'SCALAR')
        || throw('The string must be a SCALAR reference' );

    return $class->new_to_handle( IO::Scalar->new( $string_ref ) );
}

# ...

sub BUILD ($self, $) {
    (Scalar::Util::blessed( $self->{sink} ) && $self->{sink}->isa('IO::Handle') )
        || throw('The `sink` must be an instance of `IO::Handle`' );

    # TODO:
    # check to make sure the handle
    # is actually writable.
    # - SL

    $self->{context}->enter_root_context( \&start );
}

# accessors

sub sink    : ro;
sub context : ro;

# ...

sub close ($self) {
    # TODO:
    # add error checking here:
    # - make sure we are root context
    # - make sure the handle closed okay
    # - make sure we weren't already closed (for whatever reason)
    # - ... maybe more?
    $self->{sink}->close;
}

# iteration

sub is_full ($self) {
    not $self->{sink}->opened;
}

sub consume_token ($self, $token) {
    (not $self->is_full)
        || throw('Writer is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $sink       = $self->{sink};
    my $context    = $self->{context};
    my $token_type = $token->type;

    $self->log('>>> TOKEN:   ', $token->to_string                   ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, @$context ) if DEBUG;
    $self->log('    COMMA:   ', $self->{_needs_comma}               ) if DEBUG;

    if ( $self->{_needs_comma} && not(is_struct_end( $token ) || is_element_end( $token )) ) {
        $sink->print(',');
        $self->{_needs_comma} = 0;
    }

    if ( $token_type == START_OBJECT ) {
        $sink->print('{');
        $context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        $context->leave_object_context;
        $sink->print('}');
    }

    elsif ( $token_type == START_PROPERTY ) {
        $sink->print($self->make_json_string( $token->value ), ":");
        $context->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        $context->leave_property_context;
        $self->{_needs_comma} = 1;
    }

    elsif ( $token_type == START_ARRAY ) {
        $sink->print('[');
        $context->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        $context->leave_array_context;
        $sink->print(']');
    }

    elsif ( $token_type == START_ITEM ) {
        $context->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        $context->leave_item_context;
        $self->{_needs_comma} = 1;
    }

    elsif ( is_numeric( $token ) ) {
        $sink->print($token->value);
    }
    elsif ( $token_type == ADD_STRING ) {
        $sink->print( $self->make_json_string( $token->value ) );
    }
    elsif ( $token_type == ADD_TRUE ) {
        $sink->print('true');
    }
    elsif ( $token_type == ADD_FALSE ) {
        $sink->print('false');
    }
    elsif ( $token_type == ADD_NULL ) {
        $sink->print('null');
    }
    else {
        throw('Unkown token type: '.$token_type );
    }
}

# logging

sub log ($self, @msg) {
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# ...

my %esc = (
    "\n" => '\n',
    "\r" => '\r',
    "\t" => '\t',
    "\f" => '\f',
    "\b" => '\b',
    "\"" => '\"',
    "\\" => '\\\\',
    "\'" => '\\\'',
);

sub make_json_string ($self, $value) {
    $value =~ s/([\x22\x5c\n\r\t\f\b])/$esc{$1}/eg;
    $value =~ s/\//\\\//g;
    $value =~ s/([\x00-\x08\x0b\x0e-\x1f])/'\\u00' . unpack('H2', $1)/eg;

    return '"'.$value.'"';
}

1;

__END__

=pod

=cut
