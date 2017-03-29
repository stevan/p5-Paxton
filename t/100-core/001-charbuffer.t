#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Core::CharBuffer');
}

our $FILE = 't/data/100-core/001-charbuffer.txt';

subtest '... testing simple charbuffer' => sub {
    my $b = Paxton::Core::CharBuffer->new( stream => IO::File->new( $FILE ) );
    isa_ok($b, 'Paxton::Core::CharBuffer');

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
    is(exception { $b->skip(4) }, undef, '... skipped succesfully');
    is($b->current_position, 35, '... got the current position');

    is($b->peek, '7', '... peeked the expected character');
    is($b->get, '7', '... got the expected character');
    is($b->get, "\n", '... got the expected character');
    is($b->current_position, 37, '... got the current position');
};


done_testing;
