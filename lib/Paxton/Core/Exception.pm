package Paxton::Core::Exception;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Devel::StackTrace;

use overload '""' => 'to_string';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object';

has '$!message';
has '$!stack_trace' => sub { Devel::StackTrace->new( skip_frames => 4 ) };

sub BUILDARGS : init_args(
    message     => '$!message',
    stack_trace => undef,
);

my sub message     : prototype() private('$!message');
my sub stack_trace : prototype() private('$!stack_trace');

sub throw ($self) { die $self }

sub to_string ($self, @) {
    join "\n" => (
        'GAME OVER MAN! GAME OVER!',
        message,
        stack_trace->as_string
    );
}

1;

__END__

=pod

=cut

