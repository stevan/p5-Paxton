#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '[10]',
    [
        token(START_ARRAY),
            token(ADD_INT, 10),
        token(END_ARRAY),
    ],
    '... simple array'
);

done_testing;
