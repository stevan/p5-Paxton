#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Util::TokenIterator');
    use_ok('Paxton::Util::Tokens');

    use_ok('Paxton::Core::Pointer');

    use_ok('Paxton::Streaming::Pipe');
    use_ok('Paxton::Streaming::Matcher');
    use_ok('Paxton::Streaming::Decoder');
}

subtest '... basic matcher' => sub {

    my $in = Paxton::Streaming::Pipe->new(
        producer => Paxton::Util::TokenIterator->new(
            tokens => [
                token(START_OBJECT),
                    token(START_PROPERTY, "foo"),
                        token(START_OBJECT),
                            token(START_PROPERTY, "bar"),
                                token(START_OBJECT),
                                    token(START_PROPERTY, "baz"),
                                        token(ADD_STRING, "gorch"),
                                    token(END_PROPERTY),
                                token(END_OBJECT),
                            token(END_PROPERTY),
                        token(END_OBJECT),
                    token(END_PROPERTY),
                token(END_OBJECT),
            ]
        ),
        consumer => Paxton::Streaming::Matcher->new(
            pointer => Paxton::Core::Pointer->new( '/foo' )
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

    is_deeply($out->consumer->get_value, { bar => { baz => 'gorch' } }, '... got the expected decoded value');

};


done_testing;
