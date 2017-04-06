#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Decoder');
    use_ok('Paxton::Core::Tokens');
}

subtest '... object node' => sub {

    # {"foo":"bar","baz":"gorch"}
    my @tokens = (
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
        token(END_OBJECT),
    );

    my $decoder = Paxton::Streaming::Decoder->new;
    isa_ok($decoder, 'Paxton::Streaming::Decoder');

    ok(!$decoder->has_value, '... we do not have a value yet');

    $decoder->put_token( $_ ) foreach @tokens;

    ok($decoder->has_value, '... we have a value now');
    is_deeply(
        $decoder->get_value,
        { foo => 'bar', baz => 'gorch' },
        '... got the expected value'
    );
};

subtest '... array node' => sub {

    # ["bar","gorch",10,5.5]
    my @tokens = (
        token(START_ARRAY),
            token(ADD_STRING, "bar"),
            token(ADD_STRING, "gorch"),
            token(ADD_INT, 10),
            token(ADD_FLOAT, 5.5),
        token(END_ARRAY)
    );

    my $decoder = Paxton::Streaming::Decoder->new;
    isa_ok($decoder, 'Paxton::Streaming::Decoder');

    ok(!$decoder->has_value, '... we do not have a value yet');

    $decoder->put_token( $_ ) foreach @tokens;

    ok($decoder->has_value, '... we have a value now');
    is_deeply(
        $decoder->get_value,
        [ "bar", "gorch", 10, 5.5 ],
        '... got the expected value'
    );
};

done_testing;
