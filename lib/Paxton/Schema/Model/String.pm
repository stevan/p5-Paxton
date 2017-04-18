package Paxton::Schema::Model::String;

use strict;
use warnings;

use Paxton::Schema::Model::Schema;

use Paxton::Util::Errors;

our @ISA; BEGIN { @ISA = ('Paxton::Schema::Model::Schema') }
our %HAS; BEGIN {
    %HAS = (
        %Paxton::Schema::Model::Schema::HAS,
        maxLength => sub {},
        minLength => sub {},
        pattern   => sub {},
        format    => sub {},
    );
}

sub type { 'string' }

1;

__END__

=pod

=cut
