#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Core::Token');
}

subtest '... check the raw tokens' => sub {
    my @tokens = sort { $a <=> $b } enumerable::get_values_for( 'Paxton::Core::Token' => 'TokenType' );

    is( ''.$tokens[0],  'NOT_AVAILABLE',  '... got the string token value');
    is( ''.$tokens[1],  'NO_TOKEN',       '... got the string token value');
    is( ''.$tokens[2],  'START_OBJECT',   '... got the string token value');
    is( ''.$tokens[3],  'END_OBJECT',     '... got the string token value');
    is( ''.$tokens[4],  'START_PROPERTY', '... got the string token value');
    is( ''.$tokens[5],  'END_PROPERTY',   '... got the string token value');
    is( ''.$tokens[6],  'START_ARRAY',    '... got the string token value');
    is( ''.$tokens[7],  'END_ARRAY',      '... got the string token value');
    is( ''.$tokens[8],  'START_ITEM',     '... got the string token value');
    is( ''.$tokens[9],  'END_ITEM',       '... got the string token value');
    is( ''.$tokens[10], 'ADD_STRING',     '... got the string token value');
    is( ''.$tokens[11], 'ADD_INT',        '... got the string token value');
    is( ''.$tokens[12], 'ADD_FLOAT',      '... got the string token value');
    is( ''.$tokens[13], 'ADD_TRUE',       '... got the string token value');
    is( ''.$tokens[14], 'ADD_FALSE',      '... got the string token value');
    is( ''.$tokens[15], 'ADD_NULL',       '... got the string token value');
    is( ''.$tokens[16], 'ERROR',          '... got the string token value');

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
    is( 0+$tokens[13], 12, '... got the numeric token value');
    is( 0+$tokens[14], 13, '... got the numeric token value');
    is( 0+$tokens[15], 14, '... got the numeric token value');
    is( 0+$tokens[16], 15, '... got the numeric token value');
};

subtest '... check the Token contstants' => sub {

    is( ''.Paxton::Core::Token->NOT_AVAILABLE,  'NOT_AVAILABLE',  '... got the string token value');
    is( ''.Paxton::Core::Token->NO_TOKEN,       'NO_TOKEN',       '... got the string token value');
    is( ''.Paxton::Core::Token->START_OBJECT,   'START_OBJECT',   '... got the string token value');
    is( ''.Paxton::Core::Token->END_OBJECT,     'END_OBJECT',     '... got the string token value');
    is( ''.Paxton::Core::Token->START_PROPERTY, 'START_PROPERTY', '... got the string token value');
    is( ''.Paxton::Core::Token->END_PROPERTY,   'END_PROPERTY',   '... got the string token value');
    is( ''.Paxton::Core::Token->START_ARRAY,    'START_ARRAY',    '... got the string token value');
    is( ''.Paxton::Core::Token->END_ARRAY,      'END_ARRAY',      '... got the string token value');
    is( ''.Paxton::Core::Token->START_ITEM,     'START_ITEM',     '... got the string token value');
    is( ''.Paxton::Core::Token->END_ITEM,       'END_ITEM',       '... got the string token value');
    is( ''.Paxton::Core::Token->ADD_STRING,     'ADD_STRING',     '... got the string token value');
    is( ''.Paxton::Core::Token->ADD_INT,        'ADD_INT',        '... got the string token value');
    is( ''.Paxton::Core::Token->ADD_FLOAT,      'ADD_FLOAT' ,     '... got the string token value');
    is( ''.Paxton::Core::Token->ADD_TRUE,       'ADD_TRUE',       '... got the string token value');
    is( ''.Paxton::Core::Token->ADD_FALSE,      'ADD_FALSE',      '... got the string token value');
    is( ''.Paxton::Core::Token->ADD_NULL,       'ADD_NULL',       '... got the string token value');
    is( ''.Paxton::Core::Token->ERROR,          'ERROR',          '... got the string token value');

    is( 0+Paxton::Core::Token->NOT_AVAILABLE,  -1, '... got the numeric token value');
    is( 0+Paxton::Core::Token->NO_TOKEN,       0,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->START_OBJECT,   1,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->END_OBJECT,     2,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->START_PROPERTY, 3,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->END_PROPERTY,   4,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->START_ARRAY,    5,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->END_ARRAY,      6,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->START_ITEM,     7,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->END_ITEM,       8,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->ADD_STRING,     9,  '... got the numeric token value');
    is( 0+Paxton::Core::Token->ADD_INT,        10, '... got the numeric token value');
    is( 0+Paxton::Core::Token->ADD_FLOAT,      11, '... got the numeric token value');
    is( 0+Paxton::Core::Token->ADD_TRUE,       12, '... got the numeric token value');
    is( 0+Paxton::Core::Token->ADD_FALSE,      13, '... got the numeric token value');
    is( 0+Paxton::Core::Token->ADD_NULL,       14, '... got the numeric token value');
    is( 0+Paxton::Core::Token->ERROR,          15, '... got the numeric token value');
};


done_testing;
