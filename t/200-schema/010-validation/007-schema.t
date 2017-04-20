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
    my $schema = Paxton::Schema::Type::Schema->new;
    isa_ok($schema, 'Paxton::Schema::Type::Schema');

    eq_or_diff(
        [ map $_->message, $schema->validate( undef ) ],
        [ 'Error(BadInput) - got: (undef) expected: (schema)' ],
        '... got the expected error messages'
    );

    is($schema->validate( {} ), undef, '... validated successfully!');


};


done_testing;
