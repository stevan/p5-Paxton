#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use IO::File;

BEGIN {
    use_ok('Paxton::Util::TokenIterator');
    use_ok('Paxton::Util::Tokens');

    use_ok('Paxton::Core::Pointer');

    use_ok('Paxton::Streaming::Pipe');
    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Streaming::Matcher');
    use_ok('Paxton::Streaming::Decoder');
}

subtest '... basic matcher' => sub {

    my $in = Paxton::Streaming::Pipe->new(
        producer => Paxton::Streaming::Reader->new_from_handle(
            IO::File->new( 't/data/012-matcher/010-complex.json', 'r')
        ),
        consumer => Paxton::Streaming::Matcher->new(
            pointer => Paxton::Core::Pointer->new( '/0/friends/1/name' )
        ),
    );
    isa_ok($in, 'Paxton::Streaming::Pipe');

    is(exception { $in->run }, undef, '... ran the pipe successfully');

    my $out = Paxton::Streaming::Pipe->new(
        producer => Paxton::Util::TokenIterator->new(
            tokens => [ $in->consumer->get_matched_tokens ]
        ),
        consumer => Paxton::Streaming::Decoder->new,
    );
    isa_ok($out, 'Paxton::Streaming::Pipe');

    is(exception { $out->run }, undef, '... ran the pipe successfully');

    is($out->consumer->get_value, 'Valdez Mcbride', '... got the expected decoded value');

};


done_testing;
