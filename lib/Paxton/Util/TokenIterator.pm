package Paxton::Util::TokenIterator;
# ABSTRACT: Stream an array of tokens, maintining context

use strict;
use warnings;

use UNIVERSAL::Object;
use MOP::Method;

use Paxton::API::Token::Producer;

use Paxton::Core::Exception;
use Paxton::Util::Tokens;
use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_TOKEN_ITERATOR_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::API::Token::Producer') }
our %HAS;  BEGIN {
    %HAS = (
        tokens     => sub { die 'You must specify an array of `tokens` to iterate over.'},
        context    => sub { Paxton::Core::Context->new },
        # private ...
        _index => sub { 0 },
        _done  => sub { 0 },
    )
}

sub BUILD {
    my ($self) = @_;
    # initialize the state ...
    $self->{context}->enter_root_context;
}

# accessor

sub context { $_[0]->{context} }

# ...

sub is_exhausted {
    my ($self) = @_;
    return $self->{_done};
}

sub get_token {
    my ($self) = @_;

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

sub log {
    my ($self, @msg) = @_;
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# ROLE COMPOSITON

BEGIN {
    use MOP::Role;
    use MOP::Internal::Util;
    MOP::Internal::Util::APPLY_ROLES(
        MOP::Role->new(name => __PACKAGE__),
        \@DOES,
        to => 'class'
    );
}

1;

__END__

=pod

=cut
