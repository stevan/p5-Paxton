#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Trait::Provider');
    use_ok('Paxton::Mapper::ForTraits');
}

BEGIN {
    package Person;

    use strict;
    use warnings;

    use MOP;
    use UNIVERSAL::Object;

    use Method::Traits qw[ Paxton::Trait::Provider ];

    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
    our %HAS; BEGIN {
        %HAS = (
            first_name => sub { "" },
            last_name  => sub { "" },
        )
    }

    sub first_name : JSONProperty {
        my $self = shift;
        $self->{first_name} = shift if @_;
        $self->{first_name};
    }

    sub last_name : JSONProperty {
        my $self = shift;
        $self->{last_name} = shift if @_;
        $self->{last_name};
    }
}

my $pax = Paxton::Mapper::ForTraits->new;

$pax->JSON->canonical;

my $p = Person->new( first_name => 'Bob', last_name => 'Smith' );
isa_ok($p, 'Person');

is($p->first_name, 'Bob', '... got the expected first_name');
is($p->last_name, 'Smith', '... got the expected last_name');

my $json = $pax->collapse( $p );
is($json, q[{"first_name":"Bob","last_name":"Smith"}], '... got the JSON we expected');

my $obj = $pax->expand( Person => $json );
isa_ok($obj, 'Person');

is($obj->first_name, 'Bob', '... got the expected first_name');
is($obj->last_name, 'Smith', '... got the expected last_name');

done_testing;

