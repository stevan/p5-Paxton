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

## slots

has _sink         => sub { die 'You must specify a `sink` to write to.'};
has _context      => sub { Paxton::Core::Context->new };
has _needs_comma  => sub { 0 };
has _pretty_print => sub { 0 };

my sub _sink         : private;
my sub _context      : private;
my sub _needs_comma  : private;
my sub _pretty_print : private;

sub BUILDARGS : init_args( sink => '_sink', context => '_context' );

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
    (Scalar::Util::blessed( _sink ) && _sink->isa('IO::Handle') )
        || throw('The `sink` must be an instance of `IO::Handle`' );

    # TODO:
    # check to make sure the handle
    # is actually writable.
    # - SL

    _context->enter_root_context( \&start );
}

# accessors

sub sink    : ro('_sink');
sub context : ro('_context');

# ...

sub close ($self) {
    # TODO:
    # add error checking here:
    # - make sure we are root context
    # - make sure the handle closed okay
    # - make sure we weren't already closed (for whatever reason)
    # - ... maybe more?
    _sink->close;
}

# iteration

sub is_full ($self) {
    not _sink->opened;
}

sub consume_token ($self, $token) {
    (not $self->is_full)
        || throw('Writer is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $token_type = $token->type;

    $self->log('>>> TOKEN:   ', $token->to_string                         ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, _context->@* ) if DEBUG;
    $self->log('    COMMA:   ', _needs_comma                              ) if DEBUG;

    if ( _needs_comma && not(is_struct_end( $token ) || is_element_end( $token )) ) {
        _sink->print(',');
        _needs_comma = 0;
    }

    if ( $token_type == START_OBJECT ) {
        _sink->print('{');
        _context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        _context->leave_object_context;
        _sink->print('}');
    }

    elsif ( $token_type == START_PROPERTY ) {
        _sink->print($self->make_json_string( $token->value ), ":");
        _context->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        _context->leave_property_context;
        _needs_comma = 1;
    }

    elsif ( $token_type == START_ARRAY ) {
        _sink->print('[');
        _context->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        _context->leave_array_context;
        _sink->print(']');
    }

    elsif ( $token_type == START_ITEM ) {
        _context->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        _context->leave_item_context;
        _needs_comma = 1;
    }

    elsif ( is_numeric( $token ) ) {
        _sink->print($token->value);
    }
    elsif ( $token_type == ADD_STRING ) {
        _sink->print( $self->make_json_string( $token->value ) );
    }
    elsif ( $token_type == ADD_TRUE ) {
        _sink->print('true');
    }
    elsif ( $token_type == ADD_FALSE ) {
        _sink->print('false');
    }
    elsif ( $token_type == ADD_NULL ) {
        _sink->print('null');
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
