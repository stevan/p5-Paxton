#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '[]',
    [ token(START_ARRAY), token(END_ARRAY) ],
    '... simple empty array'
);

tokens_match(
    '    []',
    [ token(START_ARRAY), token(END_ARRAY) ],
    '... simple empty array w/ prefixed spaces'
);

tokens_match(
    '[    ]',
    [ token(START_ARRAY), token(END_ARRAY) ],
    '... simple empty array w/ spaces'
);

tokens_match(
    '[]    ',
    [ token(START_ARRAY), token(END_ARRAY) ],
    '... simple empty array w/ trailing spaces'
);

done_testing;
