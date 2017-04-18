package Paxton::Schema::Structure::Definitions;
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
        _defs => sub { +{} },
    );
}

sub BUILDARGS {
    my $class = shift;
    my $deps  = $class->SUPER::BUILDARGS( @_ );
    return { _defs => $deps }
}

sub to_json_schema {
    my ($self) = @_;

    my %definitions;

    foreach my $key ( keys %{ $self->{_defs} } ) {
        $definitions{ $key } = $self->{_defs}->{ $key }->to_json_schema;
    }

    return \%definitions;
}

1;

__END__

=pod

=cut
