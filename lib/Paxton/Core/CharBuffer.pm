package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs
use strict;
use warnings;

use Scalar::Util ();

use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor';

use constant MAX_BUFFER_SIZE => 512;

use parent 'UNIVERSAL::Object';
use slots (
    _handle => sub { die 'You must specify a `handle`' },
    _size   => sub { MAX_BUFFER_SIZE },
    _buffer => sub { '' },
    _done   => sub { 1 },
);

## constructor

sub BUILDARGS : strict(
    handle => '_handle',
    size?  => '_size',
);

## ...

sub BUILD {
    my ($self) = @_;

    (Scalar::Util::blessed( $self->{_handle} ) && $self->{_handle}->isa('IO::Handle') )
        || throw('You must specify a `handle` that is derived from IO::Handle' );
}

## methods

sub current_position {
    my ($self) = @_;
    $self->{_handle}->tell - length $self->{_buffer};
}

sub is_done {
    my ($self) = @_;
    # when done is undef, we are done (sorry, odd I know)
    not defined $self->{_done}
}

sub get {
    my ($self) = @_;
    $self->{_done} // return;
    ($self->{_buffer} ne ''
        ? substr( $self->{_buffer}, 0, 1, '' )
        : $self->{_handle}->read( $self->{_buffer}, $self->{_size} )
            ? substr( $self->{_buffer}, 0, 1, '' )
            : undef $self->{_done});
}

sub peek {
    my ($self) = @_;
    $self->{_done} // return;
    $self->{_buffer} ne ''
        ? substr( $self->{_buffer}, 0, 1 )
        : $self->{_handle}->read( $self->{_buffer}, $self->{_size} )
            ? substr( $self->{_buffer}, 0, 1 )
            : undef $self->{_done};
}

sub skip {
    my ($self, $n) = @_;

    $n //= 1;

    $self->{_done} // return;

    my $len = length $self->{_buffer};
    if ( $n == $len ) {
        $self->{_buffer} = '';
    }
    elsif ( $n < $len ) {
        substr( $self->{_buffer}, 0, $n, '' )
    }
    elsif ( $n > $len ) {
        $self->{_buffer} = '';
        $self->{_handle}->read( my $x, ($n - $len) );
    }
}

sub discard_whitespace_and_peek {
    my ($self) = @_;

    $self->{_done} // return;

    do {
        if ( length $self->{_buffer} == 0 ) {
            $self->{_handle}->read( $self->{_buffer}, $self->{_size} )
                or undef $self->{_done};
        }
    } while ( $self->{_buffer} =~ s/^\s+// );

    return defined $self->{_done} ? substr( $self->{_buffer}, 0, 1 ) : undef;
}

1;

__END__

=pod

=cut
