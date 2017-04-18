#!perl

use strict;
use warnings;

use Test::More;
use IO::File;
use Data::Dumper;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::String');
    use_ok('Paxton::Schema::Type::Schema');
    use_ok('Paxton::Schema::Type::Object');
    use_ok('Paxton::Schema::Type::Number');
    use_ok('Paxton::Schema::Type::Null');
    use_ok('Paxton::Schema::Type::Boolean');
    use_ok('Paxton::Schema::Type::Array');

    use_ok('Paxton::Schema::Structure::Properties');
}

# test simple types ...

subtest '... test simple string' => sub {
    my $str = Paxton::Schema::Type::String->new(
        minLength => 8,
        maxLength => 32,
    );
    isa_ok($str, 'Paxton::Schema::Type::String');

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
    my $num = Paxton::Schema::Type::Number->new(
        minimum => 8,
        maximum => 32,
    );
    isa_ok($num, 'Paxton::Schema::Type::Number');

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
    my $bool = Paxton::Schema::Type::Boolean->new;
    isa_ok($bool, 'Paxton::Schema::Type::Boolean');

    is_deeply(
        $bool->to_json_schema,
        {
            type => 'boolean',
        },
        '... got the schema we expected'
    );
};

subtest '... test simple null' => sub {
    my $null = Paxton::Schema::Type::Null->new;
    isa_ok($null, 'Paxton::Schema::Type::Null');

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
    my $array = Paxton::Schema::Type::Array->new(
        items    => Paxton::Schema::Type::Boolean->new,
        minItems => 1,
        maxItems => 10,
    );
    isa_ok($array, 'Paxton::Schema::Type::Array');

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
    my $object = Paxton::Schema::Type::Object->new(
        properties => Paxton::Schema::Structure::Properties->new(
            foo => Paxton::Schema::Type::Boolean->new,
            bar => Paxton::Schema::Type::String->new( minLength => 1 ),
        ),
        additionalProperties => Paxton::Schema::Structure::Properties->new(
            baz => Paxton::Schema::Type::Null->new,
        )
    );
    isa_ok($object, 'Paxton::Schema::Type::Object');

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
