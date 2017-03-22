package Paxton::Schema::Core::Schema::Ref;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub new {
    my ($class, $uri) = @_;
    bless \$uri => $class
}

sub to_HASH { +{ '$ref' => ${ $_[0] } } }

1;

__END__

=pod

=cut
