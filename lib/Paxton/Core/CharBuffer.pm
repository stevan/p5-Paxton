package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Carp         ();
use Scalar::Util ();
use UNIVERSAL::Object;

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
        || Carp::confess('You must specify a `handle` that is derived from IO::Handle');
}

sub current_position {
    my ($self) = @_;
    $self->{handle}->tell - length $self->{buffer};
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
    substr( $self->{buffer}, 0, ($n // 1), '' );
}

1;

__END__

=pod

=cut
