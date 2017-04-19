#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Boolean');
}

=pod

TODO:

=cut

subtest '... test simple boolean' => sub {
    my $bool = Paxton::Schema::Type::Boolean->new;
    isa_ok($bool, 'Paxton::Schema::Type::Boolean');

    eq_or_diff(
        [ map $_->message, $bool->validate( undef ) ],
        [
            'Error(BadInput) - got: (undef) expected: (boolean)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( [] ) ],
        [
            'Error(BadType) - got: (ARRAY) expected: (boolean)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( 'foo' ) ],
        [
            'Error(BadType) - got: (foo) expected: (boolean)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( \100 ) ],
        [
            'Error(BadValue) - got: (\100) expected: (boolean)'
        ],
        '... got the expected error messages'
    );

    is(
        $bool->validate( \1 ),
        undef,
        '... validated successfully!'
    );

    is(
        $bool->validate( \0 ),
        undef,
        '... validated successfully!'
    );
};


done_testing;
