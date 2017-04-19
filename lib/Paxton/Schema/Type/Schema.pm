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

sub name { 'schema' }

sub validate {
    my ($self, $value) = @_;

    my @errors = $self->SUPER::validate( $value );

    # ...

    return @errors if @errors;
    return;
}

1;

__END__

=pod

=cut
