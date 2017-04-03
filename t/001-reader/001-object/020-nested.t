#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Core::Tokens;

tokens_match(
    '{ "simple" : {} }',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "simple"),
                token(START_OBJECT),
                token(END_OBJECT),
            token(END_PROPERTY),
        token(END_OBJECT)
    ],
    '... simple nested object'
);

tokens_match(
    '{ "simple" : { "two" : { "levels" : "deep" } } }',
    [
        token(START_OBJECT),
            token(START_PROPERTY, "simple"),
                token(START_OBJECT),
                    token(START_PROPERTY, "two"),
                        token(START_OBJECT),
                            token(START_PROPERTY, "levels"),
                                token(ADD_STRING, "deep"),
                            token(END_PROPERTY),
                        token(END_OBJECT),
                    token(END_PROPERTY),
                token(END_OBJECT),
            token(END_PROPERTY),
        token(END_OBJECT)
    ],
    '... deeply nested object'
);


done_testing;
