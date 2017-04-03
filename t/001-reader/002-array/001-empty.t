#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Core::Tokens');
}


subtest '... simple empty array' => sub {
    my $r = Paxton::Streaming::Reader->new_from_string('[]');
    isa_ok($r, 'Paxton::Streaming::Reader');

    my $t1 = $r->next_token;
    ok(is_token( $t1 ), '... we got a token');
    is($t1->type, START_ARRAY, '... and it is the expected first token');

    my $t2 = $r->next_token;
    ok(is_token( $t2 ), '... we got a token');
    is($t2->type, END_ARRAY, '... and it is the expected last token');

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

subtest '... simple empty array w/ spaces' => sub {
    my $r = Paxton::Streaming::Reader->new_from_string('   []');
    isa_ok($r, 'Paxton::Streaming::Reader');

    my $t1 = $r->next_token;
    ok(is_token( $t1 ), '... we got a token');
    is($t1->type, START_ARRAY, '... and it is the expected first token');

    my $t2 = $r->next_token;
    ok(is_token( $t2 ), '... we got a token');
    is($t2->type, END_ARRAY, '... and it is the expected last token');

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

subtest '... simple empty array w/ spaces' => sub {
    my $r = Paxton::Streaming::Reader->new_from_string('[   ]');
    isa_ok($r, 'Paxton::Streaming::Reader');

    my $t1 = $r->next_token;
    ok(is_token( $t1 ), '... we got a token');
    is($t1->type, START_ARRAY, '... and it is the expected first token');

    my $t2 = $r->next_token;
    ok(is_token( $t2 ), '... we got a token');
    is($t2->type, END_ARRAY, '... and it is the expected last token');

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

subtest '... simple empty array w/ spaces' => sub {
    my $r = Paxton::Streaming::Reader->new_from_string('[]   ');
    isa_ok($r, 'Paxton::Streaming::Reader');

    my $t1 = $r->next_token;
    ok(is_token( $t1 ), '... we got a token');
    is($t1->type, START_ARRAY, '... and it is the expected first token');

    my $t2 = $r->next_token;
    ok(is_token( $t2 ), '... we got a token');
    is($t2->type, END_ARRAY, '... and it is the expected last token');

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

done_testing;
