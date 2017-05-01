package Paxton::Streaming::TokenIterator;
# ABSTRACT: Stream an array of tokens, maintining context
use Moxie;

use MOP::Method;

use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_TOKEN_ITERATOR_DEBUG} // 0;

# ...

extends 'Moxie::Object';
   with 'Paxton::Streaming::API::Producer';

has 'tokens'  => sub { die 'You must specify an array of `tokens` to iterate over.'};
has 'context' => sub { Paxton::Core::Context->new };
# private ...
has '_index'  => sub { 0 };
has '_done'   => sub { 0 };

sub BUILD ($self, $) {
    # initialize the state ...
    $self->{context}->enter_root_context;
}

# accessor

sub context : ro;

# ...

sub is_exhausted : ro('_done');

sub produce_token ($self) {
    return if $self->{_done};

    my $idx = $self->{_index};
    $self->{_index}++;

    if ( $self->{_index} >= scalar @{ $self->{tokens} } ) {
        $self->{_done} = 1;
    }

    my $token      = $self->{tokens}->[ $idx ];
    my $context    = $self->{context};
    my $token_type = $token->type;

    if ( $token_type == START_OBJECT ) {
        $context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        $context->leave_object_context;
    }
    elsif ( $token_type == START_PROPERTY ) {
        $context->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        $context->leave_property_context;
    }
    elsif ( $token_type == START_ARRAY ) {
        $context->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        $context->leave_array_context;
    }
    elsif ( $token_type == START_ITEM ) {
        $context->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        $context->leave_item_context;
    }

    return $token;
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
