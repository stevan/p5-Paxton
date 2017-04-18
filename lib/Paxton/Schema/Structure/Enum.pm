package Paxton::Schema::Structure::Enum;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object::Immutable;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        _members => sub { +[] },
    );
}

sub BUILDARGS {
    my ($class, @args) = @_;
    return { _members => \@args }
}

sub to_json_schema {
    my ($self) = @_;
    return { enum => [ @{ $self->{_members} } ] };
}

1;

__END__

=pod

=cut
