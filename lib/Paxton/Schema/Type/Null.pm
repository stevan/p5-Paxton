package Paxton::Schema::Type::Null;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadValue;

extends 'Moxie::Object::Immutable';
   with 'Paxton::Schema::API::Type';

sub name ($) { 'null' }

sub validate ($self, $value) {
    my @errors;

    if ( defined $value ) {
        push @errors => Paxton::Schema::Error::BadValue->new( got => $value, expected => $self );
    }

    return @errors if @errors;
    return;
}

1;

__END__

=pod

=cut
