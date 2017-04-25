package Paxton::Util::Schemas::AsTypeConstraint;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Util::Schemas ();

use Paxton::Schema::Util::TypeConstraint;

our @EXPORT;
BEGIN {
    @EXPORT = @Paxton::Util::Schemas::EXPORT;

    foreach my $export ( @EXPORT ) {
        no strict 'refs';
        # grab the sub we want to wrap ...
        my $orig = \&{'Paxton::Util::Schemas::'.$export};
        # now create a local version that
        # wraps the result of the $orig in
        # TypeConstraint object ...
        *{ $export } = sub {
            Paxton::Schema::Util::TypeConstraint->new( type => $orig->( @_ ) )
        };
    }
}

sub import { (shift)->import_into( scalar caller, @_ ) }

sub import_into {
    my (undef, $into, @export) = @_;
    @export = @EXPORT unless @export;
    no strict 'refs';
    *{$into.'::'.$_} = \&{$_} foreach @export;
}

1;

__END__

=pod

=cut
