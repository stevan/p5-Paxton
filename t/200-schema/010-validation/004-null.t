#!perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

BEGIN {
    use_ok('Paxton');
    use_ok('Paxton::Schema::Type::Null');
}

=pod

TODO:

=cut

subtest '... test simple null' => sub {
    my $bool = Paxton::Schema::Type::Null->new;
    isa_ok($bool, 'Paxton::Schema::Type::Null');

    eq_or_diff(
        [ map $_->message, $bool->validate( 1 ) ],
        [
            'Error(BadValue) - got: (1) expected: (null)'
        ],
        '... got the expected error messages'
    );

    eq_or_diff(
        [ map $_->message, $bool->validate( 'foo' ) ],
        [
            'Error(BadValue) - got: (foo) expected: (null)'
        ],
        '... got the expected error messages'
    );

    is(
        $bool->validate( undef ),
        undef,
        '... validated successfully!'
    );

};


done_testing;
