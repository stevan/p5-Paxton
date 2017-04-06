#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::Writer');
    use_ok('Paxton::Core::Tokens');
}

subtest '... simple object' => sub {
    my $json = '';

    my $w = Paxton::Streaming::Writer->new_to_string( \$json );
    isa_ok($w, 'Paxton::Streaming::Writer');

    my @tokens = (
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
        token(END_OBJECT)
    );

    foreach ( @tokens ) {
        $w->put_token( $_ );
    }

    ok(!$w->is_done, '... we are not done yet');
    is(exception { $w->close }, undef, '... closed the writer');
    ok($w->is_done, '... we are done now');

    is($json, '{"foo":"bar","baz":"gorch"}', '... got the JSON we expected');
};

subtest '... simple array' => sub {
    my $json = '';

    my $w = Paxton::Streaming::Writer->new_to_string( \$json );
    isa_ok($w, 'Paxton::Streaming::Writer');

    my @tokens = (
        token(START_ARRAY),
            token(ADD_STRING, "bar"),
            token(ADD_STRING, "gorch"),
            token(ADD_INT, 10),
            token(ADD_FLOAT, 5.5),
        token(END_ARRAY)
    );

    foreach ( @tokens ) {
        $w->put_token( $_ );
    }

    ok(!$w->is_done, '... we are not done yet');
    is(exception { $w->close }, undef, '... closed the writer');
    ok($w->is_done, '... we are done now');

    is($json, '["bar","gorch",10,5.5]', '... got the JSON we expected');
};


done_testing;
