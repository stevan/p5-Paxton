package Paxton::Schema::Structure::Properties;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

extends 'Moxie::Object::Immutable';

has '_props' => sub { +{} };

sub BUILDARGS ($class, @args) {
    my $deps = $class->next::method( @args );
    return { _props => $deps }
}

sub to_json_schema ($self) {
    my %properties;

    foreach my $key ( keys $self->{_props}->%* ) {
        if ( $key eq 'default' ) {
            $properties{ $key } = $self->{_props}->{ $key };
        }
        else {
            $properties{ $key } = $self->{_props}->{ $key }->to_json_schema;
        }
    }

    return \%properties;
}

1;

__END__

=pod

=cut
