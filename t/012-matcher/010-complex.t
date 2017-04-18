#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use IO::File;

BEGIN {
    use_ok('Paxton::Streaming::TokenIterator');
    use_ok('Paxton::Util::Tokens');

    use_ok('Paxton::Core::Pointer');

    use_ok('Paxton::Streaming::IO::Reader');
    use_ok('Paxton::Streaming::Matcher');
    use_ok('Paxton::Streaming::Decoder');
}

subtest '... basic matcher' => sub {

    my $in = Paxton::Streaming::IO::Reader->new_from_handle(
        IO::File->new( 't/data/012-matcher/010-complex.json', 'r')
    );
    isa_ok($in, 'Paxton::Streaming::IO::Reader');

    my $matcher = Paxton::Streaming::Matcher->new(
        pointer => Paxton::Core::Pointer->new( '/0/friends/1/name' )
    );
    isa_ok($matcher, 'Paxton::Streaming::Matcher');

    is(exception { $matcher->consume( $in ) }, undef, '... ran the consumer successfully');

    my $matched = Paxton::Streaming::TokenIterator->new(
        tokens => [ $matcher->get_matched_tokens ]
    );
    isa_ok($matched, 'Paxton::Streaming::TokenIterator');

    my $decoder = Paxton::Streaming::Decoder->new;
    isa_ok($decoder, 'Paxton::Streaming::Decoder');

    is(exception { $decoder->consume( $matched ) }, undef, '... ran the consumer successfully');

    is($decoder->get_value, 'Valdez Mcbride', '... got the expected decoded value');

};


done_testing;
