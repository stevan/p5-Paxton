#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Test::More;

BEGIN {
    unless (eval 'use Moose ();1;') {
        plan skip_all => 'Moose is required for this test';
        done_testing;
        exit;
    }

    use_ok('Paxton::Util::Schemas::AsTypeConstraint');
}

package SomeMooseClass {
    use Moose;

    use Paxton::Util::Schemas::AsTypeConstraint;

    has 'foo' => (
        is  => 'ro',
        isa => string( maxLength => 25 )
    );
}

{
    my $smc = SomeMooseClass->new;
    isa_ok($smc, 'SomeMooseClass');

    is($smc->foo, undef, '... no value');
}

{
    my $smc;
    is(
        exception { $smc = SomeMooseClass->new( foo => 'testing' ) },
        undef,
        '... constructed the instance successfully'
    );
    isa_ok($smc, 'SomeMooseClass');

    is($smc->foo, 'testing', '... got the expected value');
}

{
    like(
        exception { SomeMooseClass->new( foo => 'testing,testing,testing,testing' ) },
        qr/^Attribute \(foo\) does not pass the type constraint because\:/,
        '... did not constructed the instance (as expected)'
    );
}

done_testing;
