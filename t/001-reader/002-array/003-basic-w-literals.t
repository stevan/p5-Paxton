#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '[true]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_TRUE),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ true'
);

tokens_match(
    '[false]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_FALSE),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ false'
);

tokens_match(
    '[null]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_NULL),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ null'
);

done_testing;
