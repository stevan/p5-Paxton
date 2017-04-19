#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Integer');
}

=pod

TODO:
- test `exclusive{Min,Max}imum`
- test `multipleOf`

=cut

subtest '... test simple integer' => sub {
    my $int = Paxton::Schema::Type::Integer->new(
        minimum => 8,
        maximum => 12,
    );
    isa_ok($int, 'Paxton::Schema::Type::Integer');

    eq_or_diff(
        [ map $_->message, $int->validate( undef ) ],
        [
            'Error(BadInput) - got: (undef) expected: (integer)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( \1 ) ],
        [
            'Error(BadType) - got: (SCALAR) expected: (integer)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( 'foo' ) ],
        [
            'Error(BadType) - got: (foo) expected: (integer)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( 100 ) ],
        [
            'Error(ExceedsRange) - got: (100) expected: (min: 8, max: 12)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $int->validate( 5 ) ],
        [
            'Error(ExceedsRange) - got: (5) expected: (min: 8, max: 12)'
        ],
        '... got the expected error messages'
    );

    is(
        $int->validate( 10 ),
        undef,
        '... validated successfully!'
    );
};


done_testing;
