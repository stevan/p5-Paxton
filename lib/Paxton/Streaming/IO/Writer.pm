package Paxton::Streaming::IO::Writer;
# ABSTRACT: Convert a stream of tokens into a JSON string
use strict;
use warnings;

use Carp         ();
use Scalar::Util ();

use IO::Handle;
use IO::Scalar;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor', ':accessors';

use constant DEBUG => $ENV{PAXTON_WRITER_DEBUG} // 0;

# ...

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Consumer';
use slots (
    _sink         => sub { die 'You must specify a `sink` to write to.'},
    _context      => sub { Paxton::Core::Context->new },
    _needs_comma  => sub { 0 },
    _pretty_print => sub { 0 },
);

sub BUILDARGS : strict(
    sink     => '_sink',
    context? => '_context'
);

## Constructors

sub new_to_handle {
    my ($class, $handle) = @_;

    (Scalar::Util::blessed( $handle ) && $handle->isa('IO::Handle') )
        || throw('The stream must be derived from IO::Handle' );

    $class->new( sink => $handle );
}

sub new_to_string {
    my ($class, $string_ref) = @_;

    (defined $string_ref && ref $string_ref eq 'SCALAR')
        || throw('The string must be a SCALAR reference' );

    return $class->new_to_handle( IO::Scalar->new( $string_ref ) );
}

# ...

sub BUILD {
    my ($self) = @_;

    (Scalar::Util::blessed( $self->{_sink} ) && $self->{_sink}->isa('IO::Handle') )
        || throw('The `sink` must be an instance of `IO::Handle`' );

    # TODO:
    # check to make sure the handle
    # is actually writable.
    # - SL

    $self->{_context}->enter_root_context( \&start );
}

# accessors

sub sink    : ro(_);
sub context : ro(_);

# ...

sub close {
    my ($self) = @_;
    # TODO:
    # add error checking here:
    # - make sure we are root context
    # - make sure the handle closed okay
    # - make sure we weren't already closed (for whatever reason)
    # - ... maybe more?
    $self->{_sink}->close;
}

# iteration

sub is_full {
    my ($self) = @_;
    not $self->{_sink}->opened;
}

sub consume_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || throw('Writer is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $token_type = $token->type;

    $self->log('>>> TOKEN:   ', $token->to_string                         ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, @{ $self->{_context} } ) if DEBUG;
    $self->log('    COMMA:   ', $self->{_needs_comma}                              ) if DEBUG;

    if ( $self->{_needs_comma} && not(is_struct_end( $token ) || is_element_end( $token )) ) {
        $self->{_sink}->print(',');
        $self->{_needs_comma} = 0;
    }

    if ( $token_type == START_OBJECT ) {
        $self->{_sink}->print('{');
        $self->{_context}->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        $self->{_context}->leave_object_context;
        $self->{_sink}->print('}');
    }

    elsif ( $token_type == START_PROPERTY ) {
        $self->{_sink}->print($self->make_json_string( $token->value ), ":");
        $self->{_context}->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        $self->{_context}->leave_property_context;
        $self->{_needs_comma} = 1;
    }

    elsif ( $token_type == START_ARRAY ) {
        $self->{_sink}->print('[');
        $self->{_context}->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        $self->{_context}->leave_array_context;
        $self->{_sink}->print(']');
    }

    elsif ( $token_type == START_ITEM ) {
        $self->{_context}->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        $self->{_context}->leave_item_context;
        $self->{_needs_comma} = 1;
    }

    elsif ( is_numeric( $token ) ) {
        $self->{_sink}->print($token->value);
    }
    elsif ( $token_type == ADD_STRING ) {
        $self->{_sink}->print( $self->make_json_string( $token->value ) );
    }
    elsif ( $token_type == ADD_TRUE ) {
        $self->{_sink}->print('true');
    }
    elsif ( $token_type == ADD_FALSE ) {
        $self->{_sink}->print('false');
    }
    elsif ( $token_type == ADD_NULL ) {
        $self->{_sink}->print('null');
    }
    else {
        throw('Unkown token type: '.$token_type );
    }
}

# logging

sub log {
    my ($self, @msg) = @_;

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

sub make_json_string {
    my ($self, $value) = @_;

    $value =~ s/([\x22\x5c\n\r\t\f\b])/$esc{$1}/eg;
    $value =~ s/\//\\\//g;
    $value =~ s/([\x00-\x08\x0b\x0e-\x1f])/'\\u00' . unpack('H2', $1)/eg;

    return '"'.$value.'"';
}

1;

__END__

=pod

=cut
