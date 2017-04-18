package Paxton::Schema::Model::Array;

use strict;
use warnings;

use Scalar::Util ();

use Paxton::Schema::Model::Schema;

our @ISA; BEGIN { @ISA = ('Paxton::Schema::Model::Schema') }
our %HAS; BEGIN {
    %HAS = (
        %Paxton::Schema::Model::Schema::HAS,
        items           => sub {},
        additionalItems => sub {},
        maxItems        => sub {},
        minItems        => sub {},
        uniqueItems     => sub {},
    );
}

sub type { 'array' }

sub to_json_schema {
    my ($self) = @_;

    my $schema = $self->SUPER::to_json_schema;

    if ( my $items = $schema->{items} ) {
        if ( ref $items eq 'ARRAY' ) {
            $schema->{items} = [ map $_->to_json_schema, @$items ];
        }
        else {
            $schema->{items} = $items->to_json_schema;
        }
    }

    if ( my $additionalItems = $schema->{additionalItems} ) {
        if (Scalar::Util::blessed( $additionalItems ) && $additionalItems->isa('Paxton::Schema::Model::Schema')) {
            $schema->{additionalItems} = [ map $_->to_json_schema, @$additionalItems ];
        }
        else {
            $schema->{additionalItems} = $additionalItems->to_json_schema;
        }
    }

    return $schema;
}

1;

__END__

=pod

=cut
