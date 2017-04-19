#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Schema');
}

=pod

TODO:

=cut

subtest '... test simple schema' => sub {
    my $bool = Paxton::Schema::Type::Schema->new;
    isa_ok($bool, 'Paxton::Schema::Type::Schema');

    eq_or_diff(
        [ map $_->message, $bool->validate( undef ) ],
        [
            'Error(BadInput) - got: (undef) expected: (schema)'
        ],
        '... got the expected error messages'
    );

    is(
        $bool->validate( {} ),
        undef,
        '... validated successfully!'
    );

};


done_testing;
