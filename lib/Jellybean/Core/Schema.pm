package Jellybean::Core::Schema;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

sub new {
    my ($class, %args) = @_;
    bless \%args => $class
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
