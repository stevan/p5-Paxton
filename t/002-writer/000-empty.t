#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Writer');
    use_ok('Paxton::Core::Tokens');
}

subtest '... simple object' => sub {
    my $json = '';

    my $w = Paxton::Streaming::Writer->new_to_string( \$json );
    isa_ok($w, 'Paxton::Streaming::Writer');

    $w->put_token( $_ )
        foreach (
            token(START_OBJECT),
                token(START_PROPERTY, "foo"),
                    token(ADD_STRING, "bar"),
                token(END_PROPERTY),
                token(START_PROPERTY, "baz"),
                    token(ADD_STRING, "gorch"),
                token(END_PROPERTY),
            token(END_OBJECT)
        );

    is($json, '{"foo":"bar","baz":"gorch"}', '... got the JSON we expected');
};


done_testing;
