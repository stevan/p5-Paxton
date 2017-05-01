package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Scalar::Util ();
use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant MAX_BUFFER_SIZE => 512;

extends 'Moxie::Object';

has 'handle' => sub { die 'You must specify a `handle`' };
has 'buffer' => sub { '' };
has 'size'   => \&MAX_BUFFER_SIZE;
has 'done'   => sub { 1 };

sub BUILD ($self, $) {
    (Scalar::Util::blessed( $self->{handle} ) && $self->{handle}->isa('IO::Handle') )
        || throw('You must specify a `handle` that is derived from IO::Handle' );
}

sub current_position ($self) {
    $self->{handle}->tell - length $self->{buffer};
}

sub is_done ($self) {
    # when done is undef, we are done (sorry, odd I know)
    not defined $self->{done}
}

sub get ($self) {
    $self->{done} // return;
    ($self->{buffer} ne ''
        ? substr( $self->{buffer}, 0, 1, '' )
        : $self->{handle}->read( $self->{buffer}, $self->{size} )
            ? substr( $self->{buffer}, 0, 1, '' )
            : undef $self->{done});
}

sub peek ($self) {
    $self->{done} // return;
    $self->{buffer} ne ''
        ? substr( $self->{buffer}, 0, 1 )
        : $self->{handle}->read( $self->{buffer}, $self->{size} )
            ? substr( $self->{buffer}, 0, 1 )
            : undef $self->{done};
}

sub skip  ($self, $n = 1) {

    $self->{done} // return;

    my $len = length $self->{buffer};
    if ( $n == $len ) {
        $self->{buffer} = '';
    }
    elsif ( $n < $len ) {
        substr( $self->{buffer}, 0, $n, '' )
    }
    elsif ( $n > $len ) {
        $self->{buffer} = '';
        $self->{handle}->read( my $x, ($n - $len) );
    }
}

sub discard_whitespace_and_peek ($self) {

    $self->{done} // return;

    do {
        if ( length $self->{buffer} == 0 ) {
            $self->{handle}->read( $self->{buffer}, $self->{size} )
                or undef $self->{done};
        }
    } while ( $self->{buffer} =~ s/^\s+// );

    return defined $self->{done} ? substr( $self->{buffer}, 0, 1 ) : undef;
}

1;

__END__

=pod

=cut
