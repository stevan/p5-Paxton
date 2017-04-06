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
        reader => sub { die 'You must specify an `reader`' },
        writer => sub { die 'You must specify an `writer`' },
    )
}

# ...

sub BUILD {
    my ($self) = @_;

    # TODO:
    # We need to test that:
    #
    # - the reader does the Core::API::Reader role
    # - the writer does the Core::API::Writer role
    #
    # Just need a nice way to check it,
    # and need to actually compose the
    # roles as well.
    # - SL
}

# accessors

sub reader { $_[0]->{reader} }
sub writer { $_[0]->{writer} }

# ...

sub get_token { $_[0]->{reader}->get_token }
sub put_token { $_[0]->{writer}->put_token( $_[1] ) }

sub process_token {
    my ($self) = @_;
    my $token = $self->get_token;
    return unless defined $token;
    $self->put_token( $token );
    return 1;
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
