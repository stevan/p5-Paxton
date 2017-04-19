package Paxton::Schema::Combinator::AllOf;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object::Immutable;

use Paxton::Schema::API::Type;

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our @DOES; BEGIN { @DOES = ('Paxton::Schema::API::Type') }
our %HAS;  BEGIN {
    %HAS = (
        allOf => sub { +[] }
    );
}

# This is an intersecton type (https://www.typescriptlang.org/docs/handbook/advanced-types.html)

sub name { 'allOf' }

sub validate {
    my ($self, $value) = @_;

    my @errors;

    push @errors => Paxton::Schema::Error::BadInput->new( expected => $self )
        if not defined $value;

    return @errors if @errors;
    return;
}

# ROLE COMPOSITON

BEGIN {
    use MOP::Role;
    use MOP::Internal::Util;

    MOP::Internal::Util::APPLY_ROLES(
        MOP::Role->new(name => __PACKAGE__),
        \@DOES,
        to => 'class'
    );
}

1;

__END__

=pod

=cut
