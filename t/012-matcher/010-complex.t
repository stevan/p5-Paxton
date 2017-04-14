#!perl

use strict;
use warnings;

use Test::More;

use IO::File;

BEGIN {
    use_ok('Paxton::Util::Tokens');

    use_ok('Paxton::Core::Pointer');

    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Streaming::Matcher');
    use_ok('Paxton::Streaming::Decoder');
}

subtest '... basic matcher' => sub {

    my $in = Paxton::Streaming::Reader->new_from_handle(
        IO::File->new( 't/data/012-matcher/010-complex.json', 'r')
    );
    isa_ok($in, 'Paxton::Streaming::Reader');

    my $ptr = Paxton::Core::Pointer->new( '/0/friends/1/name' );
    isa_ok($ptr, 'Paxton::Core::Pointer');

    my $m = Paxton::Streaming::Matcher->new( pointer => $ptr );
    isa_ok($m, 'Paxton::Streaming::Matcher');

    my $d = Paxton::Streaming::Decoder->new;
    isa_ok($d, 'Paxton::Streaming::Decoder');

    do {
        $m->put_token( $in->get_token );
    } until ( $in->is_exhausted || $m->is_full );

    my $out = $m->get_matched_token_iterator;
    isa_ok($out, 'Paxton::Util::TokenIterator');

    do {
        $d->put_token( $out->get_token );
    } until ( $out->is_exhausted || $d->is_full );

    #use Data::Dumper;
    #warn Dumper $d->get_value;

    is($d->get_value, 'Valdez Mcbride', '... got the expected decoded value');

};


done_testing;
