package Paxton::Schema::Structure::Items;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object::Immutable';

has '_items' => sub { +[] };

sub BUILDARGS ($class, @args) {
    return { _items => \@args }
}

sub to_json_schema ($self) {
    return [ map $_->to_json_schema, $self->{_items}->@* ];
}

1;

__END__

=pod

=cut
