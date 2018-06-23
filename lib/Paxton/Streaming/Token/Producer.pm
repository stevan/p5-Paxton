package Paxton::Streaming::Token::Producer;
# ABSTRACT: Stream an array of tokens, maintining context
use strict;
use warnings;

use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor', ':accessors';

use constant DEBUG => $ENV{PAXTON_TOKEN_ITERATOR_DEBUG} // 0;

# ...

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Producer';
use slots (
    _source  => sub { die 'You must specify an array of `source` to iterate over.'},
    _context => sub { Paxton::Core::Context->new },
    _index   => sub { 0 },
    _done    => sub { 0 },
);

## constructor

sub BUILDARGS : strict(
    source   => '_source',
    context? => '_context',
);

sub BUILD {
    my ($self) = @_;
    # initialize the state ...
    $self->{_context}->enter_root_context;
}

# accessor

sub context : ro(_);

# ...

sub is_exhausted : ro(_done);

sub produce_token {
    my ($self) = @_;

    return if $self->{_done};

    my $idx = $self->{_index};
    $self->{_index}++;

    if ( $self->{_index} >= scalar @{ $self->{_source} } ) {
        $self->{_done} = 1;
    }

    my $token      = $self->{_source}->[ $idx ];
    my $token_type = $token->type;

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

    return $token;
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
