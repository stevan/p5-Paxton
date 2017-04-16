#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::IO::Writer');
    use_ok('Paxton::Streaming::Encoder');
}

my $source = {
    Str    => 'a string',
    Int    => 10,
    Num    => 50.25,
    Array  => [ 'another string', 200, 50.5, { bob => 'alice' }, \1 ],
    Object => { foo => 'bar', baz => [ 'gorch', 100, {}, undef ] }
};

my $json = '';

my $e = Paxton::Streaming::Encoder->new( source => $source );
isa_ok($e, 'Paxton::Streaming::Encoder');

my $w = Paxton::Streaming::IO::Writer->new_to_string( \$json );
isa_ok($w, 'Paxton::Streaming::IO::Writer');

is(exception { $w->consume( $e ) }, undef, '... ran the consumer successfully');

is_deeply(
    $json,
    '{"Array":["another string",200,50.5,{"bob":"alice"},true],"Int":10,"Num":50.25,"Object":{"baz":["gorch",100,{},null],"foo":"bar"},"Str":"a string"}',
    '... got the string we expected'
);

done_testing;
