package Paxton::Schema::API::Type;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use MOP::Role;

our %HAS; BEGIN {
    %HAS = (
        description => sub {},
        default     => sub {},
    );
}

sub to_json_schema {
    my $self      = $_[0];
    my $class     = ref $self;
    my @namespace = split /\:\:/ => $class;
    my $category  = lc $namespace[-2];
    my $type      = lc $namespace[-1];
    my $schema    = {};

    $schema->{type} = $type
        if $category eq 'type'
        && $type     ne 'schema';

    foreach my $slot ( MOP::Role->new( $class )->all_slots ) {

        my $name  = $slot->name;
        my $value = $self->{ $name };

        next unless defined $value;

        # let things that know how
        # to copy themselves, copy
        # themselves, ...
        if ( Scalar::Util::blessed( $value ) && $value->can('to_json_schema') ) {
            $value = $value->to_json_schema;
        }
        # ..and then copy the things
        # that can't copy themselves
        elsif ( ref $value eq 'HASH' ) {
            $value = {
                map {
                    Scalar::Util::blessed( $value->{ $_ } ) && $value->{ $_ }->can('to_json_schema')
                        ? ($_ => $value->{ $_ }->to_json_schema)
                        : ($_ => $value->{ $_ })
                } keys %$value
            };
        }
        elsif ( ref $value eq 'ARRAY' ) {
            $value = [
                map {
                    Scalar::Util::blessed( $_ ) && $_->can('to_json_schema')
                        ? $_->to_json_schema
                        : $_
                } @$value
            ];
        }

        $schema->{ $name } = $value;
    }

    return $schema;
}

1;

__END__
