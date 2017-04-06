#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Encoder');
    use_ok('Paxton::Core::Tokens');
}

subtest '... simple object' => sub {
    my $source = { foo => 'bar', baz => 'gorch' };
    my @tokens = (
        token(START_OBJECT),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
        token(END_OBJECT)
    );

    my $e = Paxton::Streaming::Encoder->new( source => $source );
    isa_ok($e, 'Paxton::Streaming::Encoder');

    while ( my $got = $e->get_token ) {
        my $expected = shift @tokens;
        diag $got->as_string;
        diag $expected->as_string;
        is_deeply( $got, $expected, '... got the expected token' );
    }

    is(scalar(@tokens), 0, '... exhausted all the tokens');

};

# tokens_decode_into(
#     [ "bar", "gorch", 10, 5.5 ],
#     [
#         token(START_ARRAY),
#             token(ADD_STRING, "bar"),
#             token(ADD_STRING, "gorch"),
#             token(ADD_INT, 10),
#             token(ADD_FLOAT, 5.5),
#         token(END_ARRAY)
#     ],
#     '... simple array'
# );

done_testing;
