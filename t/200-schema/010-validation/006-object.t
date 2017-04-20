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
    my $schema = Paxton::Schema::Type::Object->new;
    isa_ok($schema, 'Paxton::Schema::Type::Object');

    eq_or_diff(
        [ map $_->message, $schema->validate( undef ) ],
        [ 'Error(BadInput) - got: (undef) expected: (object)' ],
        '... got the expected error messages'
    );

    is($schema->validate( {} ), undef, '... validated successfully!');

};


done_testing;
