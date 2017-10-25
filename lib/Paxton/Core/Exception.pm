package Paxton::Core::Exception;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Devel::StackTrace;

use overload '""' => 'to_string';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object';

## slots

has _message     => sub { '' };
has _stack_trace => sub { Devel::StackTrace->new( skip_frames => 4 ) };

my sub _message     : private;
my sub _stack_trace : private;

## constructor

sub BUILDARGS : init_args(
    message? => '_message',
    msg?     => '_message',
);

## methods

sub throw ($self) { die $self }

sub to_string ($self, @) {
    join "\n" => (
        'GAME OVER MAN! GAME OVER!',
        _message,
        _stack_trace->as_string
    );
}

1;

__END__

=pod

=cut

