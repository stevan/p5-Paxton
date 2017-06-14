package Paxton::Streaming::Token::Consumer;
# ABSTRACT: Consume tokens stream
use Moxie;

use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_TOKEN_COLLECTOR_DEBUG} // 0;

# ...

extends 'Moxie::Object';
   with 'Paxton::Streaming::API::Consumer';

## slots

has _sink    => sub { +[] };
has _context => sub { Paxton::Core::Context->new };

my sub _sink    : private;
my sub _context : private;

## constructor

sub BUILDARGS : init_args(
    sink    => '_sink',
    context => '_context',
);

sub BUILD ($self, $) {
    # initialize the state ...
    _context->enter_root_context;
}

# accessor

sub sink    : ro('_sink');
sub context : ro('_context');

# ...

sub is_full ($self) { 0 }

sub consume_token ($self, $token) {
    (not $self->is_full)
        || throw('Writer is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $token_type = $token->type;

    $self->log('>>> TOKEN:   ', $token->to_string                         ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, _context->@* ) if DEBUG;

    if ( $token_type == START_OBJECT ) {
        _context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        _context->leave_object_context;
    }

    elsif ( $token_type == START_PROPERTY ) {
        _context->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        _context->leave_property_context;
    }

    elsif ( $token_type == START_ARRAY ) {
        _context->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        _context->leave_array_context;
    }

    elsif ( $token_type == START_ITEM ) {
        _context->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        _context->leave_item_context;
    }
    else {
        throw('Unkown token type: '.$token_type )
            unless is_scalar( $token );
    }

    push _sink->@* => $token;

    return;
}

# logging

sub log ($self, @msg) {
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

1;

__END__

=pod

=cut
