package Paxton::Core::Exception;
# ABSTRACT: One stop for all your JSON needs
use strict;
use warnings;

use Devel::StackTrace;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor';
use overload   '""' => 'to_string';

use parent 'UNIVERSAL::Object';
use slots (
    _message     => sub { '' },
    _stack_trace => sub { Devel::StackTrace->new( skip_frames => 4 ) },
);

## constructor

sub BUILDARGS : strict(
    message? => '_message',
    msg?     => '_message',
);

## methods

sub throw { die $_[0] }

sub to_string {
    my ($self) = @_;

    join "\n" => (
        'GAME OVER MAN! GAME OVER!',
        $self->{_message},
        $self->{_stack_trace}->as_string
    );
}

1;

__END__

=pod

=cut

