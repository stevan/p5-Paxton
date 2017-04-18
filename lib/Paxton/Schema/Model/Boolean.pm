package Paxton::Schema::Model::Boolean;

use strict;
use warnings;

use Paxton::Schema::Model::Schema;

our @ISA; BEGIN { @ISA = ('Paxton::Schema::Model::Schema') }
our %HAS; BEGIN {
    %HAS = (
        %Paxton::Schema::Model::Schema::HAS,
    );
}

sub type { 'boolean' }

1;

__END__

=pod

=cut
