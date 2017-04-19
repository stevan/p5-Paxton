#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::String');
}

=pod

TODO:
- test `format`
- test `pattern`

=cut

subtest '... test simple string' => sub {
    my $str = Paxton::Schema::Type::String->new(
        minLength => 8,
        maxLength => 12,
    );
    isa_ok($str, 'Paxton::Schema::Type::String');

    eq_or_diff(
        [ map $_->message, $str->validate( undef ) ],
        [
            'Error(BadInput) - got: (undef) expected: (string)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $str->validate( \1 ) ],
        [
            'Error(BadType) - got: (SCALAR) expected: (string)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $str->validate( 'foo' ) ],
        [
            'Error(BadLength) - got: (3) expected: (min: 8, max: 12)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $str->validate( 'foobarbazgorch' ) ],
        [
            'Error(BadLength) - got: (14) expected: (min: 8, max: 12)'
        ],
        '... got the expected error messages'
    );

    is(
        $str->validate( 'success!' ),
        undef,
        '... validated successfully!'
    );
};


done_testing;
