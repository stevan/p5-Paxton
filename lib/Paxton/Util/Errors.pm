package Paxton::Util::Errors;
# ABSTRACT: One stop for all your JSON needs
use strict;
use warnings;

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## TODO:
# Put all these exports into properly
# segemented export groups, etc.
# For now we can just export everything
# by default, ugly, but fixable later.
# - SL

our @EXPORT;
BEGIN {
    @EXPORT = qw[
        throw
    ];
}

sub import { (shift)->import_into( scalar caller, @_ ) }

sub import_into {
    my (undef, $into, @export) = @_;
    @export = @EXPORT unless @export;
    no strict 'refs';
    *{$into.'::'.$_} = \&{$_} foreach @export;
}

# ...

sub throw {
    my ($msg, @args) = @_;

    # if we have args, assume
    # that we need to sprintf
    $msg = sprintf $msg, @args if @args;

    Paxton::Core::Exception->new( message => $msg )->throw
}

1;

__END__

=pod

=cut
