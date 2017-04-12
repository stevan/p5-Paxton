#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Fatal;
use Test::Paxton;

BEGIN {
    use_ok('Paxton::Streaming::Writer');
    use_ok('Paxton::Util::Tokens');
}

tokens_written_to([ token(ADD_STRING, 'foo') ], '"foo"', '... string');
tokens_written_to([ token(ADD_INT, 10)       ], '10',    '... int');
tokens_written_to([ token(ADD_FLOAT, 10.5)   ], '10.5',  '... float');
tokens_written_to([ token(ADD_TRUE)          ], 'true',  '... true');
tokens_written_to([ token(ADD_FALSE)         ], 'false', '... false');
tokens_written_to([ token(ADD_NULL)          ], 'null',  '... null');

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

    ok(!$w->is_full, '... we are not done yet');
    is(exception { $w->close }, undef, '... closed the writer');
    ok($w->is_full, '... we are done now');

    is($json, '{"foo":"bar","baz":"gorch"}', '... got the JSON we expected');
};

subtest '... simple array' => sub {
    my $json = '';

    my $w = Paxton::Streaming::Writer->new_to_string( \$json );
    isa_ok($w, 'Paxton::Streaming::Writer');

    my @tokens = (
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_STRING, "bar"),
            token(END_ITEM),
            token(START_ITEM, 1),
                token(ADD_STRING, "gorch"),
            token(END_ITEM),
            token(START_ITEM, 2),
                token(ADD_INT, 10),
            token(END_ITEM),
            token(START_ITEM, 3),
                token(ADD_FLOAT, 5.5),
            token(END_ITEM),
        token(END_ARRAY)
    );

    foreach ( @tokens ) {
        $w->put_token( $_ );
    }

    ok(!$w->is_full, '... we are not done yet');
    is(exception { $w->close }, undef, '... closed the writer');
    ok($w->is_full, '... we are done now');

    is($json, '["bar","gorch",10,5.5]', '... got the JSON we expected');
};


done_testing;
