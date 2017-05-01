package Paxton::Schema::Combinator::AllOf;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object::Immutable';
   with 'Paxton::Schema::API::Type';

has 'allOf' => sub { +[] };

# This is an intersecton type (https://www.typescriptlang.org/docs/handbook/advanced-types.html)

sub name ($) { 'allOf' }

sub validate ($self, $value) {
    my @errors;

    push @errors => Paxton::Schema::Error::BadInput->new( expected => $self )
        if not defined $value;

    return @errors if @errors;
    return;
}

1;

__END__

=pod

=cut
