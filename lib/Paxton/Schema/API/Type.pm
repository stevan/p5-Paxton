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
    my $self   = $_[0];
    my $class  = ref $self;
    my $type   = lc((split /\:\:/ => $class)[-1]);
    my $schema = {};

    $schema->{type} = $type unless $type eq 'schema';

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
            $value = { %$value };
        }
        elsif ( ref $value eq 'ARRAY' ) {
            $value = [ @$value ];
        }

        $schema->{ $name } = $value;
    }

    return $schema;
}

1;

__END__
