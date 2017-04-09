package Paxton::Util::Tokens;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();

use Paxton::Core::Exception;
use Paxton::Core::Token;

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
    @EXPORT = keys %Paxton::Core::Token::TOKEN_MAP;

    foreach my $name ( keys %Paxton::Core::Token::TOKEN_MAP ) {
        no strict 'refs';
        *{$name} = \&{'Paxton::Core::Token::'.$name};
    }

    push @EXPORT => qw[
        is_boolean
        is_numeric
        is_error
        is_scalar
        is_struct_start
        is_struct_end

        token
        is_token
    ];
}

sub import { (shift)->import_into( scalar caller, @_ ) }

sub import_into {
    my (undef, $into, @export) = @_;
    @export = @EXPORT unless @export;
    no strict 'refs';
    *{$into.'::'.$_} = \&{$_} foreach @export;
}

## token constructors

sub token {
    my ($type, $value) = @_;
    return Paxton::Core::Token->new( type => $type, value => $value )
}

## useful predicates

sub is_token {
    (Scalar::Util::blessed($_[0]) && $_[0]->isa('Paxton::Core::Token'))
}

sub is_boolean {
    ($_[0]->type == ADD_TRUE || $_[0]->type == ADD_FALSE)
}

sub is_numeric {
    ($_[0]->type == ADD_INT || $_[0]->type == ADD_FLOAT)
}

sub is_error {
    ($_[0]->type == ERROR || $_[0]->type == NO_TOKEN || $_[0]->type == NOT_AVAILABLE)
}

sub is_scalar {
    ($_[0]->type == ADD_STRING || $_[0]->type == ADD_NULL || is_numeric( $_[0] ) || is_boolean( $_[0] ))
}

sub is_struct_start {
    ($_[0]->type == START_OBJECT || $_[0]->type == START_ARRAY || $_[0]->type == START_PROPERTY)
}

sub is_struct_end {
    ($_[0]->type == END_OBJECT || $_[0]->type == END_ARRAY || $_[0]->type == END_PROPERTY)
}

1;

__END__

=pod

=cut
