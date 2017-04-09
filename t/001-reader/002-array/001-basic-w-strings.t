#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '["foo"]',
    [
        token(START_ARRAY),
            token(ADD_STRING, "foo"),
        token(END_ARRAY),
    ],
    '... simple array'
);

tokens_match(
    '[  "foo"        ]',
    [
        token(START_ARRAY),
            token(ADD_STRING, "foo"),
        token(END_ARRAY),
    ],
    '... simple array w/ whitespace'
);

done_testing;
