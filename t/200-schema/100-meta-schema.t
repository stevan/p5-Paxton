#!perl

use strict;
use warnings;

use Test::More;
use IO::File;
use Data::Dumper;

BEGIN {
    use_ok('Paxton::Schema::Type::String');
    use_ok('Paxton::Schema::Type::Schema');
    use_ok('Paxton::Schema::Type::Object');
    use_ok('Paxton::Schema::Type::Number');
    use_ok('Paxton::Schema::Type::Null');
    use_ok('Paxton::Schema::Type::Boolean');
    use_ok('Paxton::Schema::Type::Array');

    use_ok('Paxton::Schema::Structure::Properties');
    use_ok('Paxton::Schema::Structure::Items');
    use_ok('Paxton::Schema::Structure::Enum');
    use_ok('Paxton::Schema::Structure::Dependencies');
    use_ok('Paxton::Schema::Structure::Definitions');

    use_ok('Paxton::Schema::Operator::AllOf');
    use_ok('Paxton::Schema::Operator::AnyOf');
    use_ok('Paxton::Schema::Operator::OneOf');

    use_ok('Paxton::Util::Schemas');
}

my $json_schema_v4 = schema(
    id          => 'http://json-schema.org/draft-04/schema#',
    '$schema'   => 'http://json-schema.org/draft-04/schema#',
    description => 'Core schema meta-schema',
    default     => {},
    definitions => definitions(
        schemaArray => array(
            minItems => 1,
            items    => { '$ref' => '#' }
        ),
        positiveInteger => number( minimum => 0 ),
        positiveIntegerDefault0 => allOf(
            { '$ref' => '#/definitions/positiveInteger' },
            { default => 0 }
        ),
        simpleTypes => enum(qw[
            array boolean integer null number object string
        ]),
        stringArray => array(
          items       => string(),
          minItems    => 1,
          uniqueItems => \1,
        ),
    ),
);

use Data::Dumper;
warn Dumper $json_schema_v4->to_json_schema;

done_testing;
