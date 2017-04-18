package Paxton::Schema::Model::Schema;

use strict;
use warnings;

use Scalar::Util ();
use MOP::Role;
use UNIVERSAL::Object::Immutable;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        id           => sub {},
        '$schema'    => sub {},
        title        => sub {},
        description  => sub {},
        default      => sub {},
        dependencies => sub {}, # object
        definitions  => sub {}, #
    );
}

sub type { 'object' }

sub to_json_schema {
    my ($self) = @_;

    my $schema = { type => $self->type };

    foreach my $slot ( MOP::Role->new( ref $self )->all_slots ) {

        my $name  = $slot->name;
        my $value = $self->{ $name };

        next unless defined $value;

        if ( $name eq 'dependencies' ) {
            my %dependencies;

            foreach my $key ( keys %$value ) {
                my $value = $value->{ $key };
                if (Scalar::Util::blessed( $value ) && $value->isa('Paxton::Schema::Model::Schema')) {
                    $dependencies{ $key } = $value->to_json_schema;
                }
                elsif ( ref $value eq 'ARRAY' ) {
                    $dependencies{ $key } = [ @$value ];
                }
            }

            $value = \%dependencies;
        }
        elsif ( $name eq 'definitions' ) {
            my %definitions;

            foreach my $key ( keys %$value ) {
                $definitions{ $key } = $value->{ $key }->to_json_schema;
            }

            $value = \%definitions;
        }

        $schema->{ $name } = $value;
    }

    return $schema;
}

1;

__END__

=pod

=cut
