package Paxton::Schema::Structure::Enum;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object::Immutable';

has '_members' => sub { +[] };

sub BUILDARGS ($class, @args) {
    return { _members => \@args }
}

sub to_json_schema ($self) {
    return { enum => [ $self->{_members}->@* ] };
}

1;

__END__

=pod

=cut
