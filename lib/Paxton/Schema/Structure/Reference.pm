package Paxton::Schema::Structure::Reference;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object::Immutable';

has '_uri' => sub { +[] };

sub BUILDARGS ($class, $uri) {
    return { _uri => $uri }
}

sub to_json_schema ($self) {
    return { '$ref' => $self->{_uri} };
}

1;

__END__

=pod

=cut
