#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Path::Tiny;

BEGIN {
    use_ok('Jellybean');
    use_ok('Jellybean::Util');
    use_ok('Jellybean::Schema::JSON::Schema::V4');
}

eq_or_diff_data(

    Jellybean::Util::load_schema_from(
        'Jellybean::Schema::JSON::Schema::V4'
    )->to_HASH,

    Jellybean::Util::JSON()->decode(
        Path::Tiny::path('./share/schemas/json-schema-v4.json')->slurp
    ),

    '... our schema matched the schema'
);

done_testing;
