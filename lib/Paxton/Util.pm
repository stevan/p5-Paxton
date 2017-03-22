package Paxton::Util;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use JSON::MaybeXS ();

use Paxton::Schema::Core;

# ...

sub JSON { JSON::MaybeXS->new }

sub load_schema_from_package {
    my ($pkg) = @_;

    no strict 'refs';
    Paxton::Schema::Core::Object(
        id           => ${$pkg.'::ID'},
        '$schema'    => ${$pkg.'::SCHEMA'},
        description  => ${$pkg.'::DESCRIPTION'},
        default      => ${$pkg.'::DEFAULT'},
        dependencies => \%{$pkg.'::DEPENDENCIES'},
        definitions  => \%{$pkg.'::DEFINITIONS'},
        properties   => \%{$pkg.'::PROPERTIES'},
    )
}

1;

__END__

=pod

=cut
