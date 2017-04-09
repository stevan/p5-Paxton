package Paxton::Streaming::Pipe;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::API::Token::Processor;
use Paxton::API::Token::Producer;
use Paxton::API::Token::Consumer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_PIPE_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN {
    @DOES = (
        'Paxton::API::Token::Processor',
        'Paxton::API::Token::Producer',
        'Paxton::API::Token::Consumer'
    )
}
our %HAS;  BEGIN {
    %HAS = (
        producer => sub { die 'You must specify an `producer`' },
        consumer => sub { die 'You must specify an `consumer`' },
    )
}

# ...

sub BUILD {
    my ($self) = @_;

    # TODO:
    # We need to test that:
    #
    # - the producer does the Core::API::Token::Producer role
    # - the consumer does the Core::API::Token::Consumer role
    #
    # Just need a nice way to check it,
    # and need to actually compose the
    # roles as well.
    # - SL
}

# accessors

sub producer { $_[0]->{producer} }
sub consumer { $_[0]->{consumer} }

## fulfill the APIs

sub get_token { $_[0]->{producer}->get_token }
sub put_token { $_[0]->{consumer}->put_token( $_[1] ) }

sub process_token {
    my ($self, $token) = @_;
    return $token;
}

sub process {
    my ($self) = @_;

    until ( $self->{producer}->is_exhausted ) {
        my $token = $self->get_token;
        $token = $self->process_token( $token );
        $self->put_token( $token )
            if defined $token;
    }

    # NOTE:
    # this is problematic because
    # the `close` method is not part
    # of every consumer and not part
    # of the core API, sooooo, we need
    # to fix that (either way works)
    # - SL
    $self->{consumer}->close
        unless $self->{consumer}->is_full;
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
