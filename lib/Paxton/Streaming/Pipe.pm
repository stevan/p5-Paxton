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

# fulfill the APIs

sub producer     { $_[0]->{producer} }
sub consumer     { $_[0]->{consumer} }

sub is_exhausted { $_[0]->{producer}->is_exhausted }
sub is_full      { $_[0]->{consumer}->is_full }

# NOTE:
# the {get,put}_token API is properly
# passed through the `process_token`
# method, making it possible to re-use
# a pipe as a sigular producer or
# consumer themselves.
# - SL

sub get_token    { $_[0]->process_token( $_[0]->{producer}->get_token ) }
sub put_token    { $_[0]->{consumer}->put_token( $_[0]->process_token( $_[1] ) ) }

sub process_token {
    my ($self, $token) = @_;
    return $token;
}

## ...

sub run {
    my ($self) = @_;

    until ( $self->{producer}->is_exhausted || $self->{consumer}->is_full ) {
        my $token = $self->{producer}->get_token;
        $token = $self->process_token( $token );
        $self->{consumer}->put_token( $token );
    }

    # TODO:
    # deal with some error conditions perhaps
    # - SL

    return;
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
