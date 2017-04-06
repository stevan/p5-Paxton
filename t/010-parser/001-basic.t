#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Parser::Node');
    use_ok('Paxton::Core::Tokens');
}

subtest '... object node' => sub {
    my $expected = '{"foo":"bar","baz":"gorch"}';

    my $object_node = Paxton::Parser::Node->new(
        type     => Paxton::Parser::Node->OBJECT,
        children => [
            Paxton::Parser::Node->new(
                type     => Paxton::Parser::Node->PROPERTY,
                value    => "foo",
                children => [
                    Paxton::Parser::Node->new(
                        type  => Paxton::Parser::Node->STRING,
                        value => "bar"
                    )
                ]
            ),
            Paxton::Parser::Node->new(
                type     => Paxton::Parser::Node->PROPERTY,
                value    => "baz",
                children => [
                    Paxton::Parser::Node->new(
                        type  => Paxton::Parser::Node->STRING,
                        value => "gorch"
                    )
                ]
            )
        ]
    );

    is($object_node->to_string, $expected, '... got the stringification we expected');
};


subtest '... array node' => sub {
    my $expected = '["bar","gorch",10,5.5]';

    my $array_node = Paxton::Parser::Node->new(
        type     => Paxton::Parser::Node->ARRAY,
        children => [
            Paxton::Parser::Node->new(
                type  => Paxton::Parser::Node->STRING,
                value => "bar"
            ),
            Paxton::Parser::Node->new(
                type  => Paxton::Parser::Node->STRING,
                value => "gorch"
            ),
            Paxton::Parser::Node->new(
                type  => Paxton::Parser::Node->INT,
                value => 10
            ),
            Paxton::Parser::Node->new(
                type  => Paxton::Parser::Node->FLOAT,
                value => 5.5
            )
        ]
    );

    is($array_node->to_string, $expected, '... got the stringification we expected');
};

done_testing;
