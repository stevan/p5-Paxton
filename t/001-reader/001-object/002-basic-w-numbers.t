#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '{"foo":10}',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_INT, 10),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ integer value'
);

tokens_match(
    '{ "foo" : 10, "bar" : -100 }',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_INT, 10),
            token(END_PROPERTY),
            token(START_PROPERTY, "bar"),
                token(ADD_INT, -100),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ two integer values'
);

tokens_match(
    '{"foo":10.5}',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_FLOAT, 10.5),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ float value'
);

tokens_match(
    '{ "foo" : 10.5, "bar" : -100.103 }',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_FLOAT, 10.5),
            token(END_PROPERTY),
            token(START_PROPERTY, "bar"),
                token(ADD_FLOAT, -100.103),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ two float values'
);

tokens_match(
    '{ "foo":0, "bar": -0.1 }',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_INT, 0),
            token(END_PROPERTY),
            token(START_PROPERTY, "bar"),
                token(ADD_FLOAT, -0.1),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ mixed values'
);


done_testing;
