#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Core::Tokens');
}

subtest '... simple object' => sub {
    my @expected = (
        START_OBJECT,
            START_PROPERTY,
                ADD_STRING,
                ADD_STRING,
            END_PROPERTY,
        END_OBJECT,
    );

    my $r = Paxton::Streaming::Reader->new_from_string('{"foo":"bar"}');
    isa_ok($r, 'Paxton::Streaming::Reader');

    foreach my $e ( @expected ) {
        my $t = $r->next_token;
        ok(is_token( $t ), '... we got a token');
        is($t->type, $e, '... and it is the expected token ('.$t->type.')');
        #warn( $t->dump );
    }

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

subtest '... simple object w/ whitespace' => sub {
    my @expected = (
        START_OBJECT,
            START_PROPERTY,
                ADD_STRING,
                ADD_STRING,
            END_PROPERTY,
        END_OBJECT,
    );

    my $r = Paxton::Streaming::Reader->new_from_string('{ "foo" : "bar" }');
    isa_ok($r, 'Paxton::Streaming::Reader');

    foreach my $e ( @expected ) {
        my $t = $r->next_token;
        ok(is_token( $t ), '... we got a token');
        is($t->type, $e, '... and it is the expected token ('.$t->type.')');
        warn( $t->dump );
    }

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};


done_testing;
