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

=cut

subtest '... test simple array' => sub {
    my $bool = Paxton::Schema::Type::Array->new;
    isa_ok($bool, 'Paxton::Schema::Type::Array');

    eq_or_diff(
        [ map $_->message, $bool->validate( undef ) ],
        [
            'Error(BadInput) - got: (undef) expected: (array)'
        ],
        '... got the expected error messages'
    );

    is(
        $bool->validate( [] ),
        undef,
        '... validated successfully!'
    );

};


done_testing;
