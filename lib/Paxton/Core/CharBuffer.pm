package Paxton::Core::CharBuffer;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Scalar::Util ();
use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant MAX_BUFFER_SIZE => 512;

extends 'Moxie::Object';

has '$!handle' => sub { die 'You must specify a `handle`' };
has '$!buffer' => sub { '' };
has '$!size'   => \&MAX_BUFFER_SIZE;
has '$!done'   => sub { 1 };

sub BUILDARGS : init_args(
    handle      => '$!handle',
    buffer_size => '$!size',
    buffer      => undef,
    done        => undef,
);

my sub handle : private('$!handle');
my sub buffer : private('$!buffer');
my sub size   : private('$!size');
my sub done   : private('$!done');

sub BUILD ($self, $) {
    (Scalar::Util::blessed( handle ) && handle->isa('IO::Handle') )
        || throw('You must specify a `handle` that is derived from IO::Handle' );
}

sub current_position ($self) {
    handle->tell - length buffer;
}

sub is_done ($self) {
    # when done is undef, we are done (sorry, odd I know)
    not defined done
}

sub get ($self) {
    done // return;
    (buffer ne ''
        ? substr( buffer, 0, 1, '' )
        : handle->read( buffer, size )
            ? substr( buffer, 0, 1, '' )
            : undef done);
}

sub peek ($self) {
    done // return;
    buffer ne ''
        ? substr( buffer, 0, 1 )
        : handle->read( buffer, size )
            ? substr( buffer, 0, 1 )
            : undef done;
}

sub skip  ($self, $n = 1) {

    done // return;

    my $len = length buffer;
    if ( $n == $len ) {
        buffer = '';
    }
    elsif ( $n < $len ) {
        substr( buffer, 0, $n, '' )
    }
    elsif ( $n > $len ) {
        buffer = '';
        handle->read( my $x, ($n - $len) );
    }
}

sub discard_whitespace_and_peek ($self) {

    done // return;

    do {
        if ( length buffer == 0 ) {
            handle->read( buffer, size )
                or undef done;
        }
    } while ( buffer =~ s/^\s+// );

    return defined done ? substr( buffer, 0, 1 ) : undef;
}

1;

__END__

=pod

=cut
