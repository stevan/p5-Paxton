#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '{"foo":10}',
    [
        token(START_OBJECT),
            token(START_PROPERTY),
                token(ADD_STRING, "foo"),
                token(ADD_INT, 10),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple empty object'
);

done_testing;
