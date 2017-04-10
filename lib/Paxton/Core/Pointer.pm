package Paxton::Core::Pointer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Carp         ();
use Scalar::Util ();
use UNIVERSAL::Object;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        path => sub { die 'You must specify the `path` you want to point to.' }
    )
}

# TODO:
# Implement stuff ...
# - SL

sub path { $_[0]->{path} }

sub to_string {
    my ($self) = @_;
    return $self->{path};
}

1;

__END__

=pod

=head1 SEE ALSO

L<https://tools.ietf.org/html/rfc6901>

=cut

