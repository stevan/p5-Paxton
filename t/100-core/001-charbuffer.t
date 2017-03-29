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
    my $b = Paxton::Core::CharBuffer->new( file => IO::File->new( $FILE ) );
    isa_ok($b, 'Paxton::Core::CharBuffer');

    foreach my $i ( 1 .. 5 ) {
        is($b->peek, 'l', '... peeked the expected character');
        is($b->get, 'l', '... got the expected character');
        is($b->get, 'i', '... got the expected character');
        is($b->get, 'n', '... got the expected character');
        is($b->get, 'e', '... got the expected character');
        is($b->get, $i, '... got the expected character');
        is($b->get, "\n", '... got the expected character');
    }

    is($b->get, "\n", '... got the expected character');

    is(exception { $b->skip(4) }, undef, '... skipped succesfully');

    is($b->peek, '7', '... peeked the expected character');
    is($b->get, '7', '... got the expected character');
    is($b->get, "\n", '... got the expected character');

};


done_testing;
