#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '{"foo":true}',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_TRUE),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple empty object w/ true'
);

tokens_match(
    '{"foo":false}',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_FALSE),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple empty object w/ false'
);

tokens_match(
    '{"foo":null}',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_NULL),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple empty object w/ null'
);

done_testing;
