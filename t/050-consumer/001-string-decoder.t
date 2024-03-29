#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::IO::Reader');
    use_ok('Paxton::Streaming::Decoder');
}

my $json = q|
    {
        "Str"    : "a string",
        "Int"    : 10,
        "Num"    : 50.25,
        "Array"  : [ "another string", 200, 50.5, { "bob" : "alice" }, true ],
        "Object" : { "foo" : "bar", "baz" : [ "gorch", 100, {}, null ] }
    }
|;

my $r = Paxton::Streaming::IO::Reader->new_from_string( \$json );
isa_ok($r, 'Paxton::Streaming::IO::Reader');

my $d = Paxton::Streaming::Decoder->new;
isa_ok($d, 'Paxton::Streaming::Decoder');

is(exception { $d->consume( $r ) }, undef, '... ran the consumer successfully');

ok($d->has_value, '... we have a value');
is_deeply(
    {
        Str    => 'a string',
        Int    => 10,
        Num    => 50.25,
        Array  => [ 'another string', 200, 50.5, { bob => 'alice' }, \1 ],
        Object => { foo => 'bar', baz => [ 'gorch', 100, {}, undef ] }
    },
    $d->get_value,
    '... got the data structure we expected'
);

done_testing;
