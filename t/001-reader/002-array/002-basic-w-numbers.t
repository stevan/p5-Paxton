#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '[10]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_INT, 10),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ integer item'
);

tokens_match(
    '[ 10, -100 ]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_INT, 10),
            token(END_ITEM),
            token(START_ITEM, 1),
                token(ADD_INT, -100),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ integer items'
);

tokens_match(
    '[10.5]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_FLOAT, 10.5),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ float item'
);


tokens_match(
    '[ 10.5, -100.103 ]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_FLOAT, 10.5),
            token(END_ITEM),
            token(START_ITEM, 1),
                token(ADD_FLOAT, -100.103),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ float items'
);

tokens_match(
    '[ 0, -0.1 ]',
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_INT, 0),
            token(END_ITEM),
            token(START_ITEM, 1),
                token(ADD_FLOAT, -0.1),
            token(END_ITEM),
        token(END_ARRAY),
    ],
    '... simple array w/ mixed items'
);

done_testing;
