#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '{"foo":"bar"}',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple empty object'
);

tokens_match(
    '{  "foo" :      "bar"   }',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple empty object w/ some whitespace'
);

done_testing;
