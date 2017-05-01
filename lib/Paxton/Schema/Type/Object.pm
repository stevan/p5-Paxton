package Paxton::Schema::Type::Object;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadInput;

extends 'Moxie::Object::Immutable';
   with 'Paxton::Schema::API::Type';

has 'maxProperties';
has 'minProperties';
has 'required';
has 'properties';
has 'patternProperties';
has 'additionalProperties';

sub name ($) { 'object' }

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
