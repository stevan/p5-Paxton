#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '[true]',
    [
        token(START_ARRAY),
            token(ADD_TRUE),
        token(END_ARRAY),
    ],
    '... simple array w/ true'
);

tokens_match(
    '[false]',
    [
        token(START_ARRAY),
            token(ADD_FALSE),
        token(END_ARRAY),
    ],
    '... simple array w/ false'
);

tokens_match(
    '[null]',
    [
        token(START_ARRAY),
            token(ADD_NULL),
        token(END_ARRAY),
    ],
    '... simple array w/ null'
);

done_testing;
