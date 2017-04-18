package Paxton::Schema::Model::Object;

use strict;
use warnings;

use Paxton::Schema::Model::Schema;

our @ISA; BEGIN { @ISA = ('Paxton::Schema::Model::Schema') }
our %HAS; BEGIN {
    %HAS = (
        %Paxton::Schema::Model::Schema::HAS,
        maxProperties        => sub {},
        minProperties        => sub {},
        required             => sub {},
        properties           => sub {},
        patternProperties    => sub {},
        additionalProperties => sub {},
    );
}

sub type { 'object' }

sub to_json_schema {
    my ($self) = @_;

    my $schema = $self->SUPER::to_json_schema;

    if ( my $properties = $schema->{properties} ) {
        my %props;

        foreach my $key ( keys %$properties ) {
            $props{ $key } = $properties->{ $key }->to_json_schema;
        }

        $schema->{properties} = \%props;
    }

    if ( my $additionalProperties = $schema->{additionalProperties} ) {
        if ( ref $additionalProperties eq 'HASH' ) {
            my %additional_props;

            foreach my $key ( keys %$additionalProperties ) {
                $additional_props{ $key } = $additionalProperties->{ $key }->to_json_schema;
            }

            $schema->{additionalProperties} = \%additional_props;
        }
    }

    if ( my $patternProperties = $schema->{patternProperties} ) {
        $schema->{patternProperties} = { %$patternProperties };
    }

    return $schema;
}

1;

__END__

=pod

=cut
