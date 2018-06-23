package Paxton::Streaming::Token::Consumer;
# ABSTRACT: Consume tokens stream
use strict;
use warnings;

use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor', ':accessors';

use constant DEBUG => $ENV{PAXTON_TOKEN_COLLECTOR_DEBUG} // 0;

# ...

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Consumer';
use slots (
    _sink    => sub { +[] },
    _context => sub { Paxton::Core::Context->new },
);

## constructor

sub BUILDARGS : strict(
    sink?    => '_sink',
    context? => '_context',
);

sub BUILD {
    my ($self) = @_;
    # initialize the state ...
    $self->{_context}->enter_root_context;
}

# accessor

sub sink    : ro(_);
sub context : ro(_);

# ...

sub is_full { 0 }

sub consume_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || throw('Writer is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $token_type = $token->type;

    $self->log('>>> TOKEN:   ', $token->to_string                         ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, @{ $self->{_context} } ) if DEBUG;

    if ( $token_type == START_OBJECT ) {
        $self->{_context}->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        $self->{_context}->leave_object_context;
    }

    elsif ( $token_type == START_PROPERTY ) {
        $self->{_context}->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        $self->{_context}->leave_property_context;
    }

    elsif ( $token_type == START_ARRAY ) {
        $self->{_context}->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        $self->{_context}->leave_array_context;
    }

    elsif ( $token_type == START_ITEM ) {
        $self->{_context}->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        $self->{_context}->leave_item_context;
    }
    else {
        throw('Unkown token type: '.$token_type )
            unless is_scalar( $token );
    }

    push @{ $self->{_sink} } => $token;

    return;
}

# logging

sub log {
    my ($self, @msg) = @_;

    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

1;

__END__

=pod

=cut
