package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Scalar::Util ();
use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant MAX_BUFFER_SIZE => 512;

extends 'Moxie::Object';

## slots

has _handle => sub { die 'You must specify a `handle`' };
has _size   => \&MAX_BUFFER_SIZE;
has _buffer => sub { '' };
has _done   => sub { 1 };

my sub _handle : private;
my sub _size   : private;
my sub _buffer : private;
my sub _done   : private;

## constructor

sub BUILDARGS : init_args(
    handle => '_handle',
    size   => '_size',
);

## ...

sub BUILD ($self, $) {
    (Scalar::Util::blessed( _handle ) && _handle->isa('IO::Handle') )
        || throw('You must specify a `handle` that is derived from IO::Handle' );
}

## methods

sub current_position ($self) {
    _handle->tell - length _buffer;
}

sub is_done ($self) {
    # when done is undef, we are done (sorry, odd I know)
    not defined _done
}

sub get ($self) {
    _done // return;
    (_buffer ne ''
        ? substr( _buffer, 0, 1, '' )
        : _handle->read( _buffer, _size )
            ? substr( _buffer, 0, 1, '' )
            : undef _done);
}

sub peek ($self) {
    _done // return;
    _buffer ne ''
        ? substr( _buffer, 0, 1 )
        : _handle->read( _buffer, _size )
            ? substr( _buffer, 0, 1 )
            : undef _done;
}

sub skip  ($self, $n = 1) {

    _done // return;

    my $len = length _buffer;
    if ( $n == $len ) {
        _buffer = '';
    }
    elsif ( $n < $len ) {
        substr( _buffer, 0, $n, '' )
    }
    elsif ( $n > $len ) {
        _buffer = '';
        _handle->read( my $x, ($n - $len) );
    }
}

sub discard_whitespace_and_peek ($self) {

    _done // return;

    do {
        if ( length _buffer == 0 ) {
            _handle->read( _buffer, _size )
                or undef _done;
        }
    } while ( _buffer =~ s/^\s+// );

    return defined _done ? substr( _buffer, 0, 1 ) : undef;
}

1;

__END__

=pod

=cut
