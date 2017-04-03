#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '{ "foo" : "bar" , "baz" : "gorch" }',
    [
        token(START_OBJECT),
            token(START_PROPERTY),
                token(ADD_STRING, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY),
                token(ADD_STRING, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ 2 keys and string values'
);

tokens_match(
    '{ "foo" : "bar" ,          "baz"     :"gorch",  "bob":           "alice"}',
    [
        token(START_OBJECT),
            token(START_PROPERTY),
                token(ADD_STRING, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY),
                token(ADD_STRING, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
            token(START_PROPERTY),
                token(ADD_STRING, "bob"),
                token(ADD_STRING, "alice"),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... simple object w/ 3 keys, string values and random whitespace'
);


done_testing;
