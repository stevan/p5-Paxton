#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    q[
    {
        "Str"    : "a string",
        "Int"    : 10,
        "Num"    : 50.25,
        "Array"  : [ "another string", 200, 50.5, { "bob" : "alice" }, true ],
        "Object" : { "foo" : "bar", "baz" : [ "gorch", 100, {}, null ] }
    }
    ],
    [
        token(START_OBJECT),
            token(START_PROPERTY, "Str"),
                token(ADD_STRING, "a string"),
            token(END_PROPERTY),
            token(START_PROPERTY, "Int"),
                token(ADD_INT, 10),
            token(END_PROPERTY),
            token(START_PROPERTY, "Num"),
                token(ADD_FLOAT, 50.25),
            token(END_PROPERTY),
            token(START_PROPERTY, "Array"),
                token(START_ARRAY),
                    token(ADD_STRING, "another string"),
                    token(ADD_INT, 200),
                    token(ADD_FLOAT, 50.5),
                    token(START_OBJECT),
                        token(START_PROPERTY, "bob"),
                            token(ADD_STRING, "alice"),
                        token(END_PROPERTY),
                    token(END_OBJECT),
                    token(ADD_TRUE),
                token(END_ARRAY),
            token(END_PROPERTY),
            token(START_PROPERTY, "Object"),
                token(START_OBJECT),
                    token(START_PROPERTY, "foo"),
                        token(ADD_STRING, "bar"),
                    token(END_PROPERTY),
                    token(START_PROPERTY, "baz"),
                        token(START_ARRAY),
                            token(ADD_STRING, "gorch"),
                            token(ADD_INT, 100),
                            token(START_OBJECT),
                            token(END_OBJECT),
                            token(ADD_NULL),
                        token(END_ARRAY),
                    token(END_PROPERTY),
                token(END_OBJECT),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '... complex structure'
);

done_testing;
