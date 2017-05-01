package Paxton::Schema::Structure::Dependencies;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

extends 'Moxie::Object::Immutable';

has '_deps' => sub { +{} };

sub BUILDARGS ($class, @args) {
    my $deps = $class->next::method( @args );
    return { _deps => $deps }
}

sub to_json_schema {
    my ($self) = @_;

    my %dependencies;

    foreach my $key ( keys $self->{_deps}->%* ) {
        my $value = $self->{_deps}->{ $key };
        if (Scalar::Util::blessed( $value ) && $value->can('to_json_schema')) {
            $dependencies{ $key } = $value->to_json_schema;
        }
        elsif ( ref $value eq 'ARRAY' ) {
            $dependencies{ $key } = [ $value->@* ];
        }
    }

    return \%dependencies;
}

1;

__END__

=pod

=cut
