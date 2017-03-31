package Paxton::Core::Exception;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Carp         ();
use Scalar::Util ();
use UNIVERSAL::Object;

use Devel::StackTrace;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        message      => sub {},
        _stack_trace => sub {
            Devel::StackTrace->new(
                #skip_frames  => 1,
                #frame_filter => sub {}
            )
        }
    )
}

sub throw { die $_[0] }

sub to_string {
    my ($self) = @_;
    join "\n" => (
        'GAME OVER MAN! GAME OVER!',
        $self->{message},
        $self->{_stack_trace}->as_string
    );
}

1;

__END__

=pod

=cut

