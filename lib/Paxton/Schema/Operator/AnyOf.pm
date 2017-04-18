package Paxton::Schema::Operator::AnyOf;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object::Immutable;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        _schemas => sub { +[] }
    );
}

# This is an union type (https://www.typescriptlang.org/docs/handbook/advanced-types.html)

sub BUILDARGS {
    my ($class, @args) = @_;
    return { _schemas => \@args }
}

sub to_json_schema {
    my ($self) = @_;
    return {
        anyOf => [
            map {
                Scalar::Util::blessed( $_ ) && $_->can('to_json_schema')
                    ? $_->to_json_schema
                    : ref $_ eq 'HASH'
                        ? +{ %{ $_ } }
                        : ref $_ eq 'ARRAY'
                            ? +{ %{ $_ } }
                            : $_
            } @{ $self->{_schemas} }
        ]
    };
}

1;

__END__

=pod

=cut
