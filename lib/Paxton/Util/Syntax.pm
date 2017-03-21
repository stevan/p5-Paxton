package Paxton::Util::Syntax;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Util;

our @EXPORT_OK; BEGIN {
    @EXPORT_OK = qw[
        true false
        def  prop
    ]
}

sub import {
    shift;
    my $pkg     = caller();
    my @exports = @_ ? @_ : @EXPORT_OK;

    no strict 'refs';
    *{$pkg.'::'.$_} = \&{$_} for @exports;
}

sub true  () { Paxton::Util::JSON->true }
sub false () { Paxton::Util::JSON->false }

sub prop ($$) {
    my ($name, $schema) = @_;
    no strict 'refs';
    ${(scalar caller).'::PROPERTIES'}{$name} = $schema
}

sub def ($$) {
    my ($name, $schema) = @_;
    no strict 'refs';
    ${(scalar caller).'::DEFINITIONS'}{$name} = $schema
}

1;

__END__

=pod

=cut
