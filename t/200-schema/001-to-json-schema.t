#!perl

use strict;
use warnings;

use Test::More;
use IO::File;
use Data::Dumper;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Model');
}

# test simple types ...

subtest '... test simple string' => sub {
    my $str = Paxton::Schema::Model::String->new(
        minLength => 8,
        maxLength => 32,
    );
    isa_ok($str, 'Paxton::Schema::Model::String');

    is_deeply(
        $str->to_json_schema,
        {
            type      => 'string',
            minLength => 8,
            maxLength => 32,
        },
        '... got the schema we expected'
    );
};

subtest '... test simple number' => sub {
    my $num = Paxton::Schema::Model::Number->new(
        minimum => 8,
        maximum => 32,
    );
    isa_ok($num, 'Paxton::Schema::Model::Number');

    is_deeply(
        $num->to_json_schema,
        {
            type    => 'number',
            minimum => 8,
            maximum => 32,
        },
        '... got the schema we expected'
    );
};

subtest '... test simple boolean' => sub {
    my $bool = Paxton::Schema::Model::Boolean->new;
    isa_ok($bool, 'Paxton::Schema::Model::Boolean');

    is_deeply(
        $bool->to_json_schema,
        {
            type => 'boolean',
        },
        '... got the schema we expected'
    );
};

subtest '... test simple null' => sub {
    my $null = Paxton::Schema::Model::Null->new;
    isa_ok($null, 'Paxton::Schema::Model::Null');

    is_deeply(
        $null->to_json_schema,
        {
            type => 'null',
        },
        '... got the schema we expected'
    );
};

# test more complex types

subtest '... test simple array' => sub {
    my $array = Paxton::Schema::Model::Array->new(
        items    => Paxton::Schema::Model::Boolean->new,
        minItems => 1,
        maxItems => 10,
    );
    isa_ok($array, 'Paxton::Schema::Model::Array');

    is_deeply(
        $array->to_json_schema,
        {
            type     => 'array',
            items    => { type => 'boolean' },
            minItems => 1,
            maxItems => 10,
        },
        '... got the schema we expected'
    );
};

subtest '... test simple object' => sub {
    my $object = Paxton::Schema::Model::Object->new(
        properties => {
            foo => Paxton::Schema::Model::Boolean->new,
            bar => Paxton::Schema::Model::String->new( minLength => 1 ),
        },
        additionalProperties => {
            baz => Paxton::Schema::Model::Null->new,
        }
    );
    isa_ok($object, 'Paxton::Schema::Model::Object');

    is_deeply(
        $object->to_json_schema,
        {
            type     => 'object',
            properties => {
                foo => { type => 'boolean' },
                bar => { type => 'string', minLength => 1 },
            },
            additionalProperties => {
                baz => { type => 'null' },
            }
        },
        '... got the schema we expected'
    );
};

done_testing;
