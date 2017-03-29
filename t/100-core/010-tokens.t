#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Core::JSONToken');
}

subtest '... check the raw tokens' => sub {
    my @tokens = sort { $a <=> $b } values %Paxton::Core::JSONToken::TOKEN_MAP;

    is( ''.$tokens[0],  'NOT_AVAILABLE',  '... got the string token value');
    is( ''.$tokens[1],  'NO_TOKEN',       '... got the string token value');
    is( ''.$tokens[2],  'START_OBJECT',   '... got the string token value');
    is( ''.$tokens[3],  'END_OBJECT',     '... got the string token value');
    is( ''.$tokens[4],  'START_PROPERTY', '... got the string token value');
    is( ''.$tokens[5],  'END_PROPERTY',   '... got the string token value');
    is( ''.$tokens[6],  'START_ARRAY',    '... got the string token value');
    is( ''.$tokens[7],  'END_ARRAY',      '... got the string token value');
    is( ''.$tokens[8],  'ADD_STRING',     '... got the string token value');
    is( ''.$tokens[9],  'ADD_NUMBER',     '... got the string token value');
    is( ''.$tokens[10], 'ADD_BOOLEAN',    '... got the string token value');
    is( ''.$tokens[11], 'ADD_NULL',       '... got the string token value');
    is( ''.$tokens[12], 'ERROR',          '... got the string token value');

    is( 0+$tokens[0],  -1, '... got the numeric token value');
    is( 0+$tokens[1],   0, '... got the numeric token value');
    is( 0+$tokens[2],   1, '... got the numeric token value');
    is( 0+$tokens[3],   2, '... got the numeric token value');
    is( 0+$tokens[4],   3, '... got the numeric token value');
    is( 0+$tokens[5],   4, '... got the numeric token value');
    is( 0+$tokens[6],   5, '... got the numeric token value');
    is( 0+$tokens[7],   6, '... got the numeric token value');
    is( 0+$tokens[8],   7, '... got the numeric token value');
    is( 0+$tokens[9],   8, '... got the numeric token value');
    is( 0+$tokens[10],  9, '... got the numeric token value');
    is( 0+$tokens[11], 10, '... got the numeric token value');
    is( 0+$tokens[12], 11, '... got the numeric token value');
};

subtest '... check the Token contstants' => sub {

    is( ''.Paxton::Core::JSONToken->NOT_AVAILABLE,  'NOT_AVAILABLE',  '... got the string token value');
    is( ''.Paxton::Core::JSONToken->NO_TOKEN,       'NO_TOKEN',       '... got the string token value');
    is( ''.Paxton::Core::JSONToken->START_OBJECT,   'START_OBJECT',   '... got the string token value');
    is( ''.Paxton::Core::JSONToken->END_OBJECT,     'END_OBJECT',     '... got the string token value');
    is( ''.Paxton::Core::JSONToken->START_PROPERTY, 'START_PROPERTY', '... got the string token value');
    is( ''.Paxton::Core::JSONToken->END_PROPERTY,   'END_PROPERTY',   '... got the string token value');
    is( ''.Paxton::Core::JSONToken->START_ARRAY,    'START_ARRAY',    '... got the string token value');
    is( ''.Paxton::Core::JSONToken->END_ARRAY,      'END_ARRAY',      '... got the string token value');
    is( ''.Paxton::Core::JSONToken->ADD_STRING,     'ADD_STRING',     '... got the string token value');
    is( ''.Paxton::Core::JSONToken->ADD_NUMBER,     'ADD_NUMBER',     '... got the string token value');
    is( ''.Paxton::Core::JSONToken->ADD_BOOLEAN,    'ADD_BOOLEAN',    '... got the string token value');
    is( ''.Paxton::Core::JSONToken->ADD_NULL,       'ADD_NULL',       '... got the string token value');
    is( ''.Paxton::Core::JSONToken->ERROR,          'ERROR',          '... got the string token value');

    is( 0+Paxton::Core::JSONToken->NOT_AVAILABLE,  -1, '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->NO_TOKEN,       0,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->START_OBJECT,   1,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->END_OBJECT,     2,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->START_PROPERTY, 3,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->END_PROPERTY,   4,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->START_ARRAY,    5,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->END_ARRAY,      6,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->ADD_STRING,     7,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->ADD_NUMBER,     8,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->ADD_BOOLEAN,    9,  '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->ADD_NULL,       10, '... got the numeric token value');
    is( 0+Paxton::Core::JSONToken->ERROR,          11, '... got the numeric token value');
};


done_testing;
