#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Streaming::Token::Producer');
    use_ok('Paxton::Util::Tokens');

    use_ok('Paxton::Core::Pointer');

    use_ok('Paxton::Streaming::Matcher');
    use_ok('Paxton::Streaming::Decoder');
}

subtest '... basic matcher' => sub {

    my $in = Paxton::Streaming::Token::Producer->new(
        source => [
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
    );
    isa_ok($in, 'Paxton::Streaming::Token::Producer');

    my $matcher = Paxton::Streaming::Matcher->new(
        pointer => Paxton::Core::Pointer->new( '/foo' )
    );
    isa_ok($matcher, 'Paxton::Streaming::Matcher');

    is(exception { $matcher->consume( $in ) }, undef, '... ran the consumer successfully');

    my $matched = Paxton::Streaming::Token::Producer->new( source => [ $matcher->get_matched_tokens ] );
    isa_ok($matched, 'Paxton::Streaming::Token::Producer');

    my $decoder = Paxton::Streaming::Decoder->new;
    isa_ok($decoder, 'Paxton::Streaming::Decoder');

    is(exception { $decoder->consume( $matched ) }, undef, '... ran the consumer successfully');

    is_deeply($decoder->get_value, { bar => { baz => 'gorch' } }, '... got the expected decoded value');

};


done_testing;
