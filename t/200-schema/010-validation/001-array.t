#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Array');
}

=pod

TODO:
- test `uniqueItems`
- test `items`
- test `additionalItems`

=cut

subtest '... test simple array' => sub {
    my $bool = Paxton::Schema::Type::Array->new;
    isa_ok($bool, 'Paxton::Schema::Type::Array');

    eq_or_diff(
        [ map $_->message, $bool->validate( undef ) ],
        [ 'Error(BadInput) - got: (undef) expected: (array)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( 'foo' ) ],
        [ 'Error(BadType) - got: (foo) expected: (array)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( 10 ) ],
        [ 'Error(BadType) - got: (10) expected: (array)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( {} ) ],
        [ 'Error(BadType) - got: (HASH) expected: (array)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( \1 ) ],
        [ 'Error(BadType) - got: (SCALAR) expected: (array)' ],
        '... got the expected error messages'
    );

    is($bool->validate( [] ), undef, '... validated successfully!');
};

subtest '... test simple array w/ minItems' => sub {
    my $bool = Paxton::Schema::Type::Array->new(
        minItems => 1
    );
    isa_ok($bool, 'Paxton::Schema::Type::Array');

    eq_or_diff(
        [ map $_->message, $bool->validate( [] ) ],
        [ 'Error(BadSize) - got: (0) expected: (min: 1)' ],
        '... got the expected error messages'
    );

    is($bool->validate( [ 1 ]    ), undef, '... validated successfully!');
    is($bool->validate( [ 1, 2 ] ), undef, '... validated successfully!');
};

subtest '... test simple array w/ maxItems' => sub {
    my $bool = Paxton::Schema::Type::Array->new(
        maxItems => 3
    );
    isa_ok($bool, 'Paxton::Schema::Type::Array');

    eq_or_diff(
        [ map $_->message, $bool->validate( [ 1, 2, 3, 4 ] ) ],
        [ 'Error(BadSize) - got: (4) expected: (max: 3)' ],
        '... got the expected error messages'
    );

    is($bool->validate( []          ), undef, '... validated successfully!');
    is($bool->validate( [ 1 ]       ), undef, '... validated successfully!');
    is($bool->validate( [ 1, 2 ]    ), undef, '... validated successfully!');
    is($bool->validate( [ 1, 2, 3 ] ), undef, '... validated successfully!');
};

subtest '... test simple array w/ minItems & maxItems' => sub {
    my $bool = Paxton::Schema::Type::Array->new(
        minItems => 1,
        maxItems => 3,
    );
    isa_ok($bool, 'Paxton::Schema::Type::Array');

    eq_or_diff(
        [ map $_->message, $bool->validate( [] ) ],
        [ 'Error(BadSize) - got: (0) expected: (min: 1, max: 3)' ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( [ 1, 2, 3, 4 ] ) ],
        [ 'Error(BadSize) - got: (4) expected: (min: 1, max: 3)' ],
        '... got the expected error messages'
    );

    is($bool->validate( [ 1 ]       ), undef, '... validated successfully!');
    is($bool->validate( [ 1, 2 ]    ), undef, '... validated successfully!');
    is($bool->validate( [ 1, 2, 3 ] ), undef, '... validated successfully!');
};

done_testing;
