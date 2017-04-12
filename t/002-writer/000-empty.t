#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Fatal;
use Test::Paxton;

BEGIN {
    use_ok('Paxton::Streaming::Writer');
    use_ok('Paxton::Util::Tokens');
}

tokens_written_to([ token(ADD_STRING, 'foo') ], '"foo"', '... string');
tokens_written_to([ token(ADD_INT, 10)       ], '10',    '... int');
tokens_written_to([ token(ADD_FLOAT, 10.5)   ], '10.5',  '... float');
tokens_written_to([ token(ADD_TRUE)          ], 'true',  '... true');
tokens_written_to([ token(ADD_FALSE)         ], 'false', '... false');
tokens_written_to([ token(ADD_NULL)          ], 'null',  '... null');

tokens_written_to(
    [
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
        token(END_OBJECT)
    ],
    '{"foo":"bar","baz":"gorch"}',
    '... simple object'
);

tokens_written_to(
    [
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_STRING, "bar"),
            token(END_ITEM),
            token(START_ITEM, 1),
                token(ADD_STRING, "gorch"),
            token(END_ITEM),
            token(START_ITEM, 2),
                token(ADD_INT, 10),
            token(END_ITEM),
            token(START_ITEM, 3),
                token(ADD_FLOAT, 5.5),
            token(END_ITEM),
        token(END_ARRAY)
    ],
    '["bar","gorch",10,5.5]',
    '... simple array'
);


done_testing;
