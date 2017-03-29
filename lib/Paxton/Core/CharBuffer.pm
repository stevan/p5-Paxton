package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Carp         ();
use Scalar::Util ();

use constant MAX_BUFFER_SIZE => 512;

# accessor helpers ...
use constant _BUFFER => 0;
use constant _FILE   => 1;
use constant _SIZE   => 2;
use constant _DONE   => 3;

sub new {
    my ($class, %args) = @_;

    (exists $args{file})
        || Carp::confess('You must specify a `file`');

    (Scalar::Util::blessed( $args{file} ) && $args{file}->isa('IO::Handle') )
        || Carp::confess('You must specify a `file` that is derived from IO::Handle');

    $args{size} ||= MAX_BUFFER_SIZE;

    bless [ '', $args{file}, $args{size}, 1 ] => $class;
}

sub get {
    my ($self) = @_;
    $self->[_DONE] // return;
    ($self->[_BUFFER] ne ''
        ? substr( $self->[_BUFFER], 0, 1, '' )
        : $self->[_FILE]->read( $self->[_BUFFER], $self->[_SIZE] )
            ? substr( $self->[_BUFFER], 0, 1, '' )
            : undef $self->[_DONE]);
}

sub peek {
    my ($self) = @_;
    $self->[_DONE] // return;
    $self->[_BUFFER] ne ''
        ? substr( $self->[_BUFFER], 0, 1 )
        : $self->[_FILE]->read( $self->[_BUFFER], $self->[_SIZE] )
            ? substr( $self->[_BUFFER], 0, 1 )
            : undef $self->[_DONE];
}

sub skip {
    my ($self, $num_chars) = @_;
    my $buffer_length = length $self->[_BUFFER];
    if ( $num_chars == $buffer_length ) {
        $self->[_BUFFER] = '';
    }
    elsif ( $num_chars < $buffer_length ) {
        substr( $self->[_BUFFER], 0, $num_chars, '' )
    }
    elsif ( $num_chars > $buffer_length ) {
        $self->[_BUFFER] = '';
        $self->[_FILE]->read( my $x, ($num_chars - $buffer_length) );
    }
}

1;

__END__

=pod

=cut
