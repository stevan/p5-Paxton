package Paxton::Core::Exception;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Devel::StackTrace;

use overload '""' => 'to_string';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object';

has 'message';
has '_stack_trace' => sub {
    Devel::StackTrace->new(
        skip_frames  => 4,
        #frame_filter => sub {}
    )
};

sub throw ($self) { die $self }

sub to_string ($self, @) {
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

