#!perl

use strict;
use warnings;

use experimental 'state';

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::Pipe::Map');
    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Streaming::Decoder');
    use_ok('Paxton::Util::Tokens');
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

my $r = Paxton::Streaming::Reader->new_from_string( \$json );
isa_ok($r, 'Paxton::Streaming::Reader');

my $d = Paxton::Streaming::Decoder->new;
isa_ok($d, 'Paxton::Streaming::Decoder');

my $p = Paxton::Streaming::Pipe::Map->new(
    producer  => $r,
    consumer  => $d,
    processor => sub {
        my ($pipe, $token) = @_;

        if ( $token->type == ADD_STRING ) {
            return token( ADD_STRING, join '' => reverse split /(.)/ => $token->value );
        }
        elsif ( $token->type == ADD_INT ) {
            return token( ADD_INT, 10 + $token->value );
        }

        return $token;
    }
);
isa_ok($p, 'Paxton::Streaming::Pipe');

is($p->producer, $r, '... got the right producer');
is($p->consumer, $d, '... got the right consumer');

ok(!$p->is_done, '... the pipe is not done');
is(exception { $p->process }, undef, '... ran the pipe successfully');
ok($p->is_done, '... the pipe is done');

ok($d->has_value, '... we have a value');
is_deeply(
    {
        Str    => 'gnirts a',
        Int    => 20,
        Num    => 50.25,
        Array  => [ 'gnirts rehtona', 210, 50.5, { bob => 'ecila' }, 1 ],
        Object => { foo => 'rab', baz => [ 'hcrog', 110, {}, undef ] }
    },
    $d->get_value,
    '... got the data structure we expected'
);

#use Data::Dumper;
#warn Dumper $d->get_value;

done_testing;
