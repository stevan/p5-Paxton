#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '[ 10, [ 20, 25 ], 30 ]',
    [
        token(START_ARRAY),
            token(ADD_INT, 10),
            token(START_ARRAY),
                token(ADD_INT, 20),
                token(ADD_INT, 25),
            token(END_ARRAY),
            token(ADD_INT, 30),
        token(END_ARRAY)
    ],
    '... simple nested array'
);

tokens_match(
    '[ 10, [ 20, [[ 30, 35 ], 40 ]], 50]',
    [
        token(START_ARRAY),
            token(ADD_INT, 10),
            token(START_ARRAY),
                token(ADD_INT, 20),
                token(START_ARRAY),
                    token(START_ARRAY),
                        token(ADD_INT, 30),
                        token(ADD_INT, 35),
                    token(END_ARRAY),
                    token(ADD_INT, 40),
                token(END_ARRAY),
            token(END_ARRAY),
            token(ADD_INT, 50),
        token(END_ARRAY)
    ],
    '... simple nested array'
);

done_testing;
