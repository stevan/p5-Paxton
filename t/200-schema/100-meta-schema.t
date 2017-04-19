#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton::Streaming::Decoder');
    use_ok('Paxton::Streaming::IO::Reader');

    use_ok('Paxton::Util::Schemas');
}

my $json_schema_v4 = schema(
    id          => 'http://json-schema.org/draft-04/schema#',
    '$schema'   => 'http://json-schema.org/draft-04/schema#',
    description => 'Core schema meta-schema',
    type        => 'object',
    definitions => definitions(
        schemaArray => array(
            minItems => 1,
            items    => reference('#')
        ),
        positiveInteger => integer( minimum => 0 ),
        positiveIntegerDefault0 => allOf(
            allOf => [
                reference( '#/definitions/positiveInteger' ),
                schema( default => 0 )
            ]
        ),
        simpleTypes => enum(qw[ array boolean integer null number object string ]),
        stringArray => array(
          items       => string(),
          minItems    => 1,
          uniqueItems => \1,
        ),
    ),
    properties => properties(
        id          => string( format => 'uri' ),
        '$schema'   => string( format => 'uri' ),
        title       => string(),
        description => string(),
        default     => {},

        multipleOf       => number( minimum => 0, exclusiveMinimum => \1 ),
        maximum          => number(),
        exclusiveMaximum => boolean( default => \0 ),
        minimum          => number(),
        exclusiveMinimum => boolean( default => \0 ),

        maxLength => reference('#/definitions/positiveInteger'),
        minLength => reference('#/definitions/positiveIntegerDefault0'),
        pattern   => string( format => 'regex' ),

        additionalItems => anyOf(
            anyOf => [
                boolean(),
                reference('#')
            ],
            default => {},
        ),
        items => anyOf(
            anyOf => [
                reference('#'),
                reference('#/definitions/schemaArray')
            ],
            default => {},
        ),
        maxItems             => reference('#/definitions/positiveInteger'),
        minItems             => reference('#/definitions/positiveIntegerDefault0'),
        uniqueItems          => boolean( default => \0 ),
        maxProperties        => reference('#/definitions/positiveInteger'),
        minProperties        => reference('#/definitions/positiveIntegerDefault0'),
        required             => reference('#/definitions/stringArray'),
        additionalProperties => anyOf(
            anyOf => [
                boolean(),
                reference('#'),
            ],
            default => {}
        ),
        definitions       => object( additionalProperties => reference('#'), default => {} ),
        properties        => object( additionalProperties => reference('#'), default => {} ),
        patternProperties => object( additionalProperties => reference('#'), default => {} ),
        dependencies      => object(
            additionalProperties => anyOf(
                anyOf => [
                    reference('#'),
                    reference('#/definitions/stringArray')
                ]
            )
        ),
        enum => array(
          minItems    => 1,
          uniqueItems => \1
        ),
        type => anyOf(
            anyOf => [
                reference('#/definitions/simpleTypes'),
                array(
                    items       => reference('#/definitions/simpleTypes'),
                    minItems    =>  1,
                    uniqueItems => \1,
                )
            ]
        ),
        allOf => reference('#/definitions/schemaArray'),
        anyOf => reference('#/definitions/schemaArray'),
        oneOf => reference('#/definitions/schemaArray'),
        not   => reference('#'),
    ),
    dependencies => dependencies(
        exclusiveMaximum => ['maximum'],
        exclusiveMinimum => ['minimum'],
    ),
    default => {},
);

my $got      = $json_schema_v4->to_json_schema;
my $expected = Paxton::Streaming::Decoder->new->consume(
    Paxton::Streaming::IO::Reader->new_from_path('share/schemas/json-schema-v4.json')
)->get_value;

eq_or_diff($got, $expected, '... we generated the same structure as we had');

done_testing;
