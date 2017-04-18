package Paxton::Schema::Structure::Items;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object::Immutable;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        _items => sub { +[] },
    );
}

sub BUILDARGS {
    my ($class, @args) = @_;
    return { _items => \@args }
}

sub to_json_schema {
    my ($self) = @_;
    return [ map $_->to_json_schema, @{ $self->{_items} } ];
}

1;

__END__

=pod

=cut
