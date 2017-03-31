package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();
use UNIVERSAL::Object;

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant MAX_BUFFER_SIZE => 512;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        handle => sub { die 'You must specify a `handle`' },
        buffer => sub { '' },
        size   => sub { MAX_BUFFER_SIZE },
        done   => sub { 1 },
    )
}

sub BUILD {
    my ($self) = @_;
    (Scalar::Util::blessed( $self->{handle} ) && $self->{handle}->isa('IO::Handle') )
        || Paxton::Core::Exception->new( message => 'You must specify a `handle` that is derived from IO::Handle' )->throw;
}

sub current_position {
    my ($self) = @_;
    $self->{handle}->tell - length $self->{buffer};
}

sub is_done {
    my ($self) = @_;
    # when done is undef, we are done (sorry, odd I know)
    not defined $self->{done}
}

sub get {
    my ($self) = @_;
    $self->{done} // return;
    ($self->{buffer} ne ''
        ? substr( $self->{buffer}, 0, 1, '' )
        : $self->{handle}->read( $self->{buffer}, $self->{size} )
            ? substr( $self->{buffer}, 0, 1, '' )
            : undef $self->{done});
}

sub peek {
    my ($self) = @_;
    $self->{done} // return;
    $self->{buffer} ne ''
        ? substr( $self->{buffer}, 0, 1 )
        : $self->{handle}->read( $self->{buffer}, $self->{size} )
            ? substr( $self->{buffer}, 0, 1 )
            : undef $self->{done};
}

sub skip {
    my ($self, $n) = @_;

    $self->{done} // return;

    $n //= 1;

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

1;

__END__

=pod

=cut
