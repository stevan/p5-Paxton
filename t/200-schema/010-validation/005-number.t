#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Number');
}

=pod

TODO:
- test `exclusive{Min,Max}imum`
- test `multipleOf`

=cut

subtest '... test simple number' => sub {
    my $int = Paxton::Schema::Type::Number->new;
    isa_ok($int, 'Paxton::Schema::Type::Number');

    eq_or_diff(
        [ map $_->message, $int->validate( undef ) ],
        [ 'Error(BadInput) - got: (undef) expected: (number)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( \1 ) ],
        [ 'Error(BadType) - got: (SCALAR) expected: (number)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( 'foo' ) ],
        [ 'Error(BadType) - got: (foo) expected: (number)' ],
        '... got the expected error messages'
    );

    is($int->validate( 10.4 ), undef, '... validated successfully!');
};

subtest '... test simple number w/ minimum' => sub {
    my $int = Paxton::Schema::Type::Number->new(
        minimum => 8
    );
    isa_ok($int, 'Paxton::Schema::Type::Number');

    eq_or_diff(
        [ map $_->message, $int->validate( 5.25 ) ],
        [ 'Error(ExceedsRange) - got: (5.25) expected: (min: 8)' ],
        '... got the expected error messages'
    );

    is($int->validate( 100.01 ), undef, '... validated successfully!');
};

subtest '... test simple number w/ maximum' => sub {
    my $int = Paxton::Schema::Type::Number->new(
        maximum => 12,
    );
    isa_ok($int, 'Paxton::Schema::Type::Number');

    eq_or_diff(
        [ map $_->message, $int->validate( 100.01 ) ],
        [ 'Error(ExceedsRange) - got: (100.01) expected: (max: 12)' ],
        '... got the expected error messages'
    );

    is($int->validate( 10.25 ), undef, '... validated successfully!');
};

subtest '... test simple number w/ minimum and maximum' => sub {
    my $int = Paxton::Schema::Type::Number->new(
        minimum => 8,
        maximum => 12,
    );
    isa_ok($int, 'Paxton::Schema::Type::Number');

    eq_or_diff(
        [ map $_->message, $int->validate( 100.01 ) ],
        [ 'Error(ExceedsRange) - got: (100.01) expected: (min: 8, max: 12)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( 5.25 ) ],
        [ 'Error(ExceedsRange) - got: (5.25) expected: (min: 8, max: 12)' ],
        '... got the expected error messages'
    );

    is($int->validate( 10.314 ), undef, '... validated successfully!');
};


done_testing;
