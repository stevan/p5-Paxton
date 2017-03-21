package Paxton::Core::Schema;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util         ();
use JSON::Schema::AsType (); # temporarily

sub new {
    my ($class, %args) = @_;
    bless \%args => $class
}

my $COMPILED_SCHEMA;
sub validate {
    my ($self, $data) = @_;
    # NOTE:
    # this is likely not how we want to do this,
    # but it works for now and I don't have to
    # re-write all this logic.
    # - SL
    $COMPILED_SCHEMA ||= JSON::Schema::AsType->new( schema => $self->to_HASH );
    $COMPILED_SCHEMA->validate_explain( $data );
}

sub to_HASH {
    my $self = $_[0];
    return +{
        map {
            my $v = $self->{ $_ };
            $_ => Scalar::Util::blessed( $v ) && $v->can('to_HASH')
                ? $v->to_HASH
                : ($_ eq 'properties' || $_ eq 'definitions')
                    ? +{ map { $_ => $v->{ $_ }->to_HASH } keys %$v }
                    : ($_ eq 'anyOf' || $_ eq 'allOf' || $_ eq 'oneOf')
                        ? +[ map { $_->to_HASH } @$v ]
                        : $v
        } keys %$self
    }
}

1;

__END__

=pod

=cut
