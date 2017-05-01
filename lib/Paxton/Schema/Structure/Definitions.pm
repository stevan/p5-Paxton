package Paxton::Schema::Structure::Definitions;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

extends 'Moxie::Object::Immutable';

has '_defs' => sub { +{} };

sub BUILDARGS ($class, @args) {
    my $deps = $class->next::method( @args );
    return { _defs => $deps }
}

sub to_json_schema ($self) {
    my %definitions;

    foreach my $key ( keys $self->{_defs}->%* ) {
        $definitions{ $key } = $self->{_defs}->{ $key }->to_json_schema;
    }

    return \%definitions;
}

1;

__END__

=pod

=cut
