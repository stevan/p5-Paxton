#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::IO::Reader');
    use_ok('Paxton::Streaming::Decoder');
    use_ok('Paxton::Streaming::Parser');
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

my $reader = Paxton::Streaming::IO::Reader->new_from_string( \$json );
isa_ok($reader, 'Paxton::Streaming::IO::Reader');

my $decoder = Paxton::Streaming::Decoder->new;
isa_ok($decoder, 'Paxton::Streaming::Decoder');

my $parser = Paxton::Streaming::Parser->new;
isa_ok($parser, 'Paxton::Streaming::Parser');

is(exception { $reader->broadcast( $decoder, $parser ) }, undef, '... ran the producer successfully');

ok($decoder->has_value, '... we have a decoder value');
is_deeply(
    {
        Str    => 'a string',
        Int    => 10,
        Num    => 50.25,
        Array  => [ 'another string', 200, 50.5, { bob => 'alice' }, \1 ],
        Object => { foo => 'bar', baz => [ 'gorch', 100, {}, undef ] }
    },
    $decoder->get_value,
    '... got the data structure we expected'
);

ok($parser->has_value, '... we have a parser value');
my $tree = $parser->get_value;
isa_ok($tree, 'Paxton::Core::TreeNode');

is(
    $tree->to_string,
    '{"Str":"a string","Int":10,"Num":50.25,"Array":["another string",200,50.5,{"bob":"alice"},true],"Object":{"foo":"bar","baz":["gorch",100,{},null]}}',
    '... got the serialized TreeNode we expected'
);

done_testing;
