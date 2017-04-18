package Paxton::Schema::Model::Number;

use strict;
use warnings;

use Paxton::Schema::Model::Schema;

our @ISA; BEGIN { @ISA = ('Paxton::Schema::Model::Schema') }
our %HAS; BEGIN {
    %HAS = (
        %Paxton::Schema::Model::Schema::HAS,
        multipleOf       => sub {},
        maximum          => sub {},
        exclusiveMaximum => sub {},
        minimum          => sub {},
        exclusiveMinimum => sub {},
    );
}

sub type { 'number' }

1;

__END__

=pod

=cut
