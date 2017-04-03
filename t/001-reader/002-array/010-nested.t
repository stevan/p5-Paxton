#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '[[]]',
    [
        token(START_ARRAY),
            token(START_ARRAY),
            token(END_ARRAY),
        token(END_ARRAY)
    ],
    '... simple nested array'
);

tokens_match(
    '[[[]]]',
    [
        token(START_ARRAY),
            token(START_ARRAY),
                token(START_ARRAY),
                token(END_ARRAY),
            token(END_ARRAY),
        token(END_ARRAY)
    ],
    '... simple nested array'
);

done_testing;
