#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Fatal;
use Test::Paxton;

BEGIN {
    use_ok('Paxton::Streaming::IO::Writer');
    use_ok('Paxton::Util::Tokens');
}

tokens_written_to(
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
                    token(START_ITEM, 0),
                        token(ADD_STRING, "another string"),
                    token(END_ITEM),
                    token(START_ITEM, 1),
                        token(ADD_INT, 200),
                    token(END_ITEM),
                    token(START_ITEM, 2),
                        token(ADD_FLOAT, 50.5),
                    token(END_ITEM),
                    token(START_ITEM, 3),
                        token(START_OBJECT),
                            token(START_PROPERTY, "bob"),
                                token(ADD_STRING, "alice"),
                            token(END_PROPERTY),
                        token(END_OBJECT),
                    token(END_ITEM),
                    token(START_ITEM, 4),
                        token(ADD_TRUE),
                    token(END_ITEM),
                token(END_ARRAY),
            token(END_PROPERTY),
            token(START_PROPERTY, "Object"),
                token(START_OBJECT),
                    token(START_PROPERTY, "foo"),
                        token(ADD_STRING, "bar"),
                    token(END_PROPERTY),
                    token(START_PROPERTY, "baz"),
                        token(START_ARRAY),
                            token(START_ITEM, 0),
                                token(ADD_STRING, "gorch"),
                            token(END_ITEM),
                            token(START_ITEM, 1),
                                token(ADD_INT, 100),
                            token(END_ITEM),
                            token(START_ITEM, 2),
                                token(START_OBJECT),
                                token(END_OBJECT),
                            token(END_ITEM),
                            token(START_ITEM, 3),
                                token(ADD_NULL),
                            token(END_ITEM),
                        token(END_ARRAY),
                    token(END_PROPERTY),
                token(END_OBJECT),
            token(END_PROPERTY),
        token(END_OBJECT),
    ],
    '{"Str":"a string","Int":10,"Num":50.25,"Array":["another string",200,50.5,{"bob":"alice"},true],"Object":{"foo":"bar","baz":["gorch",100,{},null]}}',
    '... complex object'
);


done_testing;
