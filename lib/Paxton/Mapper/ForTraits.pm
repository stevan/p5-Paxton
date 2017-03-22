package Paxton::Mapper::ForTraits;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use MOP;
use Paxton::Util;

sub new {
    my ($class, $JSON) = @_;
    bless {
        JSON => $JSON // Paxton::Util::JSON(),
    } => $class;
}

sub JSON { $_[0]->{JSON} }

sub collapse {
    my $self    = shift;
    my $object  = shift;
    my $klass   = MOP::Class->new( ref $object );
    my @methods = grep $_->has_code_attributes('JSONProperty'), $klass->all_methods;

    my %data;
    foreach my $m ( @methods ) {
        my $name = $m->name;
        $data{ $name } = $object->$name();
    }

    return $self->{JSON}->encode( \%data );
}

sub expand {
    my $self    = shift;
    my $klass   = MOP::Class->new( shift );
    my $json    = $self->{JSON}->decode( shift );
    my @methods = grep $_->has_code_attributes('JSONProperty'), $klass->all_methods;

    my $object = $klass->name->new;
    foreach my $m ( @methods ) {
        my $name = $m->name;
        $object->$name( $json->{ $name } );
    }

    return $object;
}

1;

__END__

=pod

=cut
