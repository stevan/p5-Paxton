#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Parser');
    use_ok('Paxton::Streaming::Parser::Node');
    use_ok('Paxton::Util::Tokens');
}

subtest '... object node' => sub {
    my $expected = '{"foo":"bar","baz":"gorch"}';

    my @tokens = (
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
        token(END_OBJECT),
    );

    my $p = Paxton::Streaming::Parser->new;
    isa_ok($p, 'Paxton::Streaming::Parser');

    ok(!$p->has_value, '... we do not have a value yet');
    ok(!$p->is_done, '... we are not done yet');

    $p->put_token( $_ ) foreach @tokens;

    ok($p->has_value, '... we have a value now');
    ok($p->is_done, '... we are done now');

    is($p->get_value->to_string, $expected, '... got the stringification we expected');

    my $object_node = Paxton::Streaming::Parser::Node->new(
        type     => Paxton::Streaming::Parser::Node->OBJECT,
        children => [
            Paxton::Streaming::Parser::Node->new(
                type     => Paxton::Streaming::Parser::Node->PROPERTY,
                value    => "foo",
                children => [
                    Paxton::Streaming::Parser::Node->new(
                        type  => Paxton::Streaming::Parser::Node->STRING,
                        value => "bar"
                    )
                ]
            ),
            Paxton::Streaming::Parser::Node->new(
                type     => Paxton::Streaming::Parser::Node->PROPERTY,
                value    => "baz",
                children => [
                    Paxton::Streaming::Parser::Node->new(
                        type  => Paxton::Streaming::Parser::Node->STRING,
                        value => "gorch"
                    )
                ]
            )
        ]
    );

    is_deeply($p->get_value, $object_node, '... got the structure we expected');
    is($object_node->to_string, $expected, '... got the stringification we expected');
};


subtest '... array node' => sub {
    my $expected = '["bar","gorch",10,5.5]';

    my @tokens = (
        token(START_ARRAY),
            token(ADD_STRING, "bar"),
            token(ADD_STRING, "gorch"),
            token(ADD_INT, 10),
            token(ADD_FLOAT, 5.5),
        token(END_ARRAY)
    );

    my $p = Paxton::Streaming::Parser->new;
    isa_ok($p, 'Paxton::Streaming::Parser');

    ok(!$p->has_value, '... we do not have a value yet');
    ok(!$p->is_done, '... we are not done yet');

    $p->put_token( $_ ) foreach @tokens;

    ok($p->has_value, '... we have a value now');
    ok($p->is_done, '... we are done now');

    is($p->get_value->to_string, $expected, '... got the stringification we expected');

    my $array_node = Paxton::Streaming::Parser::Node->new(
        type     => Paxton::Streaming::Parser::Node->ARRAY,
        children => [
            Paxton::Streaming::Parser::Node->new(
                type  => Paxton::Streaming::Parser::Node->STRING,
                value => "bar"
            ),
            Paxton::Streaming::Parser::Node->new(
                type  => Paxton::Streaming::Parser::Node->STRING,
                value => "gorch"
            ),
            Paxton::Streaming::Parser::Node->new(
                type  => Paxton::Streaming::Parser::Node->INT,
                value => 10
            ),
            Paxton::Streaming::Parser::Node->new(
                type  => Paxton::Streaming::Parser::Node->FLOAT,
                value => 5.5
            )
        ]
    );

    is_deeply($p->get_value, $array_node, '... got the structure we expected');
    is($array_node->to_string, $expected, '... got the stringification we expected');
};

done_testing;
