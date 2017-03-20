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

my $schema = Jellybean::Util::load_schema_from('Jellybean::Schema::JSON::Schema::V4');
my $data   = Jellybean::Util::JSON()->decode(
    Path::Tiny::path('./share/schemas/json-schema-v4.json')->slurp
);

eq_or_diff_data( $schema->to_HASH, $data, '... our schema matched the stored schema' );

my $result = $schema->validate( $data );

ok( (not defined $result), '... and schema validated successfully' );

done_testing;
