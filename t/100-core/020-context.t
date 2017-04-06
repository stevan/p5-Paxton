#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Core::Context');
}

subtest '... testing simple context' => sub {
    my $c = Paxton::Core::Context->new;
    isa_ok($c, 'Paxton::Core::Context');

    is($c->depth, 0, '... in the base state');

    ok(!$c->in_root_context, '... we are not in root context (yet)');
    is(exception { $c->enter_root_context }, undef, '... entered root context successfully');
    ok($c->in_root_context, '... we are in root context');
    is($c->depth, 1, '... in the root state');

    like(
        exception { $c->enter_property_context },
        qr/Unable to enter property context from within anything but object context/,
        '... errored upon entering property context (correctly)'
    );

    ok(!$c->in_object_context, '... we are not in object context (yet)');
    is(exception { $c->enter_object_context }, undef, '... entered object context successfully');
    ok($c->in_object_context, '... we are in object context');
    is($c->depth, 2, '... in the object state');

    like(
        exception { $c->enter_array_context },
        qr/Unable to enter array context from within object context/,
        '... errored upon entering array context (correctly)'
    );

    ok(!$c->in_property_context, '... we are not in property context (yet)');
    is(exception { $c->enter_property_context }, undef, '... entered property context successfully');
    ok($c->in_property_context, '... we are in property context');
    is($c->depth, 3, '... in the property state');

    ok(!$c->in_array_context, '... we are not in array context (yet)');
    is(exception { $c->enter_array_context }, undef, '... entered array context successfully');
    ok($c->in_array_context, '... we are in array context');
    is($c->depth, 4, '... in the array state');

    like(
        exception { $c->enter_property_context },
        qr/Unable to enter property context from within anything but object context/,
        '... errored upon entering property context (correctly)'
    );

    is(exception { $c->leave_array_context }, undef, '... left array context successfully');
    ok($c->in_property_context, '... we are back into property context now');
    like(
        exception { $c->enter_property_context },
        qr/Unable to enter property context from within anything but object context/,
        '... errored upon entering property context (correctly)'
    );
    is(exception { $c->leave_property_context }, undef, '... left property context successfully');

    ok(!$c->in_property_context, '... we are not in property context (yet)');
    is(exception { $c->enter_property_context }, undef, '... entered property context successfully');
    ok($c->in_property_context, '... we are in property context');
    is($c->depth, 3, '... in the property state');
};

done_testing;


