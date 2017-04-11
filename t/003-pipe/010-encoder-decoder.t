#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::Pipe');
    use_ok('Paxton::Streaming::Decoder');
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

my $d = Paxton::Streaming::Decoder->new;
isa_ok($d, 'Paxton::Streaming::Decoder');

my $p = Paxton::Streaming::Pipe->new(
    producer => $e,
    consumer => $d,
);
isa_ok($p, 'Paxton::Streaming::Pipe');

is($p->producer, $e, '... got the right producer');
is($p->consumer, $d, '... got the right consumer');

is(exception { $p->run }, undef, '... ran the pipe successfully');

ok($d->has_value, '... we have a value');

#use Data::Dumper;
#warn Dumper $d->get_value;
#warn Dumper $source;

is_deeply(
    $source,
    $d->get_value,
    '... got the string we expected'
);

done_testing;
