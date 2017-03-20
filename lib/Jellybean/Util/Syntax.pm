package Jellybean::Util::Syntax;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Jellybean::Util;

our @EXPORT_OK; BEGIN {
    @EXPORT_OK = qw[
        true false
        def  prop
    ]
}

sub true  () { Jellybean::Util::JSON->true }
sub false () { Jellybean::Util::JSON->false }

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
