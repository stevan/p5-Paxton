package Paxton::Streaming::Pipe;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::API::Tokenizer::Producer;
use Paxton::API::Tokenizer::Consumer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_PIPE_DEBUG} // 0;

# ...

our @ISA; BEGIN { @ISA  = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        producer => sub { die 'You must specify an `producer`'  },
        consumer => sub { die 'You must specify an `consumer`'  },
    )
}

# ...

sub BUILD {
    my ($self) = @_;

    # TODO:
    # We need to test that:
    #
    # - the `producer` does the Core::API::Token::Producer role
    # - the `consumer` does the Core::API::Token::Consumer role
    #
    # Just need a nice way to check it,
    # and need to actually compose the
    # roles as well.
    # - SL
}

## accessors

sub producer { $_[0]->{producer} }
sub consumer { $_[0]->{consumer} }

## ...

sub run {
    my ($self) = @_;

    my $producer = $self->{producer};
    my $consumer = $self->{consumer};

    until (  $consumer->is_full || $producer->is_exhausted ) {
        my $token = $producer->produce_token;
        last unless defined $token;
        $consumer->consume_token( $token );
    }

    # TODO:
    # deal with some error conditions around
    # how full or exhausted everything is, ...
    # maybe.
    # - SL

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
