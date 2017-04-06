package Paxton::Streaming::Encoder;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::Core::API::Reader;

use Paxton::Core::Exception;
use Paxton::Core::Tokens;
use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_ENCODER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::Core::API::Reader') }
our %HAS;  BEGIN {
    %HAS = (
        source => sub { die 'You must specify a `source` to encode.'},
        tokens => sub { +[] }
    )
}

sub is_done {
    my ($self) = @_;
    return;
}

sub get_token {
    my ($self) = @_;
    return;
}

# logging

sub log {
    my ($self, @msg) = @_;
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# ...

1;

__END__

=pod

=cut
