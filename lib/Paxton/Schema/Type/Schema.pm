package Paxton::Schema::Type::Schema;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadInput;

extends 'Paxton::Schema::Type::Object';

has 'id';
has '$schema';
has 'title';
has 'type';
has 'dependencies';
has 'definitions';

sub name ($) { 'schema' }

sub validate ($self, $value) {
    my @errors = $self->next::method( $value );

    # ...

    return @errors if @errors;
    return;
}

1;

__END__

=pod

=cut
