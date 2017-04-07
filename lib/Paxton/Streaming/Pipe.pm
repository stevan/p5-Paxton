package Paxton::Streaming::Pipe;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::Core::API::Pipe;
use Paxton::Core::API::Reader;
use Paxton::Core::API::Writer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_PIPE_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN {
    @DOES = (
        'Paxton::Core::API::Pipe',
        'Paxton::Core::API::Reader',
        'Paxton::Core::API::Writer'
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
    # - the producer does the Core::API::Reader role
    # - the consumer does the Core::API::Writer role
    #
    # Just need a nice way to check it,
    # and need to actually compose the
    # roles as well.
    # - SL
}

# accessors

sub producer { $_[0]->{producer} }
sub consumer { $_[0]->{consumer} }

## fulfill the Pipe, Reader & Writer APIs

sub is_done {
    my ($self) = @_;
    $self->{producer}->is_done
        &&
    $self->{consumer}->is_done;
}

sub get_token { $_[0]->{producer}->get_token }
sub put_token { $_[0]->{consumer}->put_token( $_[1] ) }

sub process_token {
    my ($self) = @_;
    my $token = $self->get_token;
    $self->put_token( $token )
        if defined $token;
}

sub process {
    my ($self) = @_;
    $self->process_token
        until $self->{producer}->is_done;
    $self->{consumer}->close
        unless $self->{consumer}->is_done;
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
