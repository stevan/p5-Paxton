#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

BEGIN {
    use_ok('Paxton::Core::Tokens');
}

tokens_encoded_from(
    { foo => 'bar', baz => 'gorch' },
    [
        token(START_OBJECT),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
        token(END_OBJECT)
    ],
    '... simple object'
);

tokens_encoded_from(
    [ "bar", "gorch", 10, 5.5 ],
    [
        token(START_ARRAY),
            token(ADD_STRING, "bar"),
            token(ADD_STRING, "gorch"),
            token(ADD_INT, 10),
            token(ADD_FLOAT, 5.5),
        token(END_ARRAY)
    ],
    '... simple array'
);

done_testing;
