#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Object');
}

=pod

TODO:

=cut

subtest '... test simple object' => sub {
    my $bool = Paxton::Schema::Type::Object->new;
    isa_ok($bool, 'Paxton::Schema::Type::Object');

    eq_or_diff(
        [ map $_->message, $bool->validate( undef ) ],
        [
            'Error(BadInput) - got: (undef) expected: (object)'
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
