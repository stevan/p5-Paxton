package Paxton::Schema::Structure::Reference;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object::Immutable;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        _uri => sub { +[] },
    );
}

sub BUILDARGS {
    my ($class, $uri) = @_;
    return { _uri => $uri }
}

sub to_json_schema {
    my ($self) = @_;
    return { '$ref' => $self->{_uri} };
}

1;

__END__

=pod

=cut
