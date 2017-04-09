#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Parser');
    use_ok('Paxton::Core::TreeNode');
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
    ok(!$p->is_full, '... we are not done yet');

    $p->put_token( $_ ) foreach @tokens;

    ok($p->has_value, '... we have a value now');
    ok($p->is_full, '... we are done now');

    is($p->get_value->to_string, $expected, '... got the stringification we expected');

    my $object_node = Paxton::Core::TreeNode->new(
        type     => Paxton::Core::TreeNode->OBJECT,
        children => [
            Paxton::Core::TreeNode->new(
                type     => Paxton::Core::TreeNode->PROPERTY,
                value    => "foo",
                children => [
                    Paxton::Core::TreeNode->new(
                        type  => Paxton::Core::TreeNode->STRING,
                        value => "bar"
                    )
                ]
            ),
            Paxton::Core::TreeNode->new(
                type     => Paxton::Core::TreeNode->PROPERTY,
                value    => "baz",
                children => [
                    Paxton::Core::TreeNode->new(
                        type  => Paxton::Core::TreeNode->STRING,
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
            token(START_ITEM, 0),
                token(ADD_STRING, "bar"),
            token(END_ITEM),
            token(START_ITEM, 0),
                token(ADD_STRING, "gorch"),
            token(END_ITEM),
            token(START_ITEM, 0),
                token(ADD_INT, 10),
            token(END_ITEM),
            token(START_ITEM, 0),
                token(ADD_FLOAT, 5.5),
            token(END_ITEM),
        token(END_ARRAY)
    );

    my $p = Paxton::Streaming::Parser->new;
    isa_ok($p, 'Paxton::Streaming::Parser');

    ok(!$p->has_value, '... we do not have a value yet');
    ok(!$p->is_full, '... we are not done yet');

    $p->put_token( $_ ) foreach @tokens;

    ok($p->has_value, '... we have a value now');
    ok($p->is_full, '... we are done now');

    is($p->get_value->to_string, $expected, '... got the stringification we expected');

    my $array_node = Paxton::Core::TreeNode->new(
        type     => Paxton::Core::TreeNode->ARRAY,
        children => [
            Paxton::Core::TreeNode->new(
                type     => Paxton::Core::TreeNode->ITEM,
                value    => 0,
                children => [
                    Paxton::Core::TreeNode->new(
                        type  => Paxton::Core::TreeNode->STRING,
                        value => "bar"
                    ),
                ]
            ),
            Paxton::Core::TreeNode->new(
                type     => Paxton::Core::TreeNode->ITEM,
                value    => 0,
                children => [
                    Paxton::Core::TreeNode->new(
                        type  => Paxton::Core::TreeNode->STRING,
                        value => "gorch"
                    ),
                ]
            ),
            Paxton::Core::TreeNode->new(
                type     => Paxton::Core::TreeNode->ITEM,
                value    => 0,
                children => [
                    Paxton::Core::TreeNode->new(
                        type  => Paxton::Core::TreeNode->INT,
                        value => 10
                    ),
            ]
            ),
            Paxton::Core::TreeNode->new(
                type     => Paxton::Core::TreeNode->ITEM,
                value    => 0,
                children => [
                    Paxton::Core::TreeNode->new(
                        type  => Paxton::Core::TreeNode->FLOAT,
                        value => 5.5
                    )
                ]
            ),
        ]
    );

    is_deeply($p->get_value, $array_node, '... got the structure we expected');
    is($array_node->to_string, $expected, '... got the stringification we expected');
};

done_testing;
