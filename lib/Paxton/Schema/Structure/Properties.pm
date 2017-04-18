package Paxton::Schema::Structure::Properties;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

use UNIVERSAL::Object::Immutable;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        _props => sub { +{} },
    );
}

sub BUILDARGS {
    my $class = shift;
    my $deps  = $class->SUPER::BUILDARGS( @_ );
    return { _props => $deps }
}

sub to_json_schema {
    my ($self) = @_;

    my %properties;

    foreach my $key ( keys %{ $self->{_props} } ) {
        $properties{ $key } = $self->{_props}->{ $key }->to_json_schema;
    }

    return \%properties;
}

1;

__END__

=pod

=cut
