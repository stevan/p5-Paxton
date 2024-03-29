#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::IO::Reader');
    use_ok('Paxton::Streaming::IO::Writer');
}

my $start = '{"Array":["another string",200,50.5,{"bob":"alice"},true],"Int":10,"Num":50.25,"Object":{"baz":["gorch",100,{},null],"foo":"bar"},"Str":"a string"}';
my $end   = '';

my $r = Paxton::Streaming::IO::Reader->new_from_string( \$start );
isa_ok($r, 'Paxton::Streaming::IO::Reader');

my $w = Paxton::Streaming::IO::Writer->new_to_string( \$end );
isa_ok($w, 'Paxton::Streaming::IO::Writer');

is(exception { $w->consume( $r ) }, undef, '... ran the consumer successfully');

is($start, $end, '... got the string we expected');

done_testing;
