#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Paxton::Util::Tokens;

tokens_match(
    '{}',
    [ token(START_OBJECT), token(END_OBJECT) ],
    '... simple empty object'
);

tokens_match(
    '    {}',
    [ token(START_OBJECT), token(END_OBJECT) ],
    '... simple empty object w/ prefixed spaces'
);

tokens_match(
    '{    }',
    [ token(START_OBJECT), token(END_OBJECT) ],
    '... simple empty object w/ spaces'
);

tokens_match(
    '{}    ',
    [ token(START_OBJECT), token(END_OBJECT) ],
    '... simple empty object w/ trailing spaces'
);

done_testing;
