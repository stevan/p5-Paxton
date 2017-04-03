#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Core::Tokens');
}

subtest '... simple empty input' => sub {
    my $r = Paxton::Streaming::Reader->new_from_string('');
    isa_ok($r, 'Paxton::Streaming::Reader');

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

subtest '... simple empty input w/ spaces' => sub {
    my $r = Paxton::Streaming::Reader->new_from_string('    ');
    isa_ok($r, 'Paxton::Streaming::Reader');

    is( $r->next_token, undef, '... parsing is complete' );
    ok( $r->is_done, '... the reader is done' );
};

done_testing;
