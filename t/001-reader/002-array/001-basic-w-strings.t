#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '["foo"]',
    [
        token(START_ARRAY),
            token(ADD_STRING, "foo"),
        token(END_ARRAY),
    ],
    '... simple array'
);

done_testing;
