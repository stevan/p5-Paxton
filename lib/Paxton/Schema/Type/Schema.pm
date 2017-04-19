package Paxton::Schema::Type::Schema;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Type::Object;

our @ISA;  BEGIN { @ISA  = ('Paxton::Schema::Type::Object') }
our %HAS;  BEGIN {
    %HAS = (
        %Paxton::Schema::Type::Object::HAS,
        id           => sub {},
        '$schema'    => sub {},
        title        => sub {},
        type         => sub {},
        dependencies => sub {},
        definitions  => sub {},
    );
}

1;

__END__

=pod

=cut
