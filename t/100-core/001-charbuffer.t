#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use IO::File;
use IO::Scalar;

use Path::Tiny ();

BEGIN {
    use_ok('Paxton::Core::CharBuffer');
}

our $FILE = 't/data/100-core/001-charbuffer.txt';

subtest '... testing simple charbuffer' => sub {
    my $b = Paxton::Core::CharBuffer->new( handle => IO::File->new( $FILE ) );
    isa_ok($b, 'Paxton::Core::CharBuffer');

    test_my_buffer( $b );
};

subtest '... testing simple charbuffer w/ IO::Scalar' => sub {
    my $b = Paxton::Core::CharBuffer->new(
        handle => IO::Scalar->new(
            \(Path::Tiny::path( $FILE )->slurp)
        )
    );
    isa_ok($b, 'Paxton::Core::CharBuffer');

    test_my_buffer( $b );
};

done_testing;

sub test_my_buffer {
    my $b = shift;

    is($b->current_position, 0, '... got the current position');

    foreach my $i ( 1 .. 5 ) {
        is($b->peek, 'l', '... peeked the expected character');
        is($b->get, 'l', '... got the expected character');
        is($b->get, 'i', '... got the expected character');
        is($b->get, 'n', '... got the expected character');
        is($b->get, 'e', '... got the expected character');
        is($b->get, $i, '... got the expected character');
        is($b->get, "\n", '... got the expected character');
        is($b->current_position, (6 * $i), '... got the current position');
    }

    is($b->get, "\n", '... got the expected character');

    is($b->current_position, 31, '... got the current position');
    foreach my $i ( 1 .. 4 ) {
        my $c = $b->peek;
        is($b->current_position, 31 + ($i - 1), '... got the current position (peek did not advance)');
        is($b->skip, $c, '... skip returned the char it is discarding');
        is($b->current_position, 31 + $i, '... got the current position (skip did advance)');
    }
    is($b->current_position, 35, '... got the current position');

    is($b->peek, '7', '... peeked the expected character');
    is($b->get, '7', '... got the expected character');
    is($b->get, "\n", '... got the expected character');
    is($b->current_position, 37, '... got the current position');

    $b->skip_whitespace;
    is($b->current_position, 43, '... got the current position');
    is($b->get, 'l', '... got the expected character');
    is($b->get, 'i', '... got the expected character');
    is($b->get, 'n', '... got the expected character');
    is($b->get, 'e', '... got the expected character');
    is($b->get, '8', '... got the expected character');
    is($b->get, "\n", '... got the expected character');

}

