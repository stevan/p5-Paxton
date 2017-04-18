package Paxton::Util::Schemas;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Type::Array;
use Paxton::Schema::Type::Boolean;
use Paxton::Schema::Type::Null;
use Paxton::Schema::Type::Number;
use Paxton::Schema::Type::Object;
use Paxton::Schema::Type::Schema;
use Paxton::Schema::Type::String;

use Paxton::Schema::Structure::Definitions;
use Paxton::Schema::Structure::Dependencies;
use Paxton::Schema::Structure::Enum;
use Paxton::Schema::Structure::Items;
use Paxton::Schema::Structure::Properties;
use Paxton::Schema::Structure::Reference;

use Paxton::Schema::Operator::AllOf;
use Paxton::Schema::Operator::AnyOf;
use Paxton::Schema::Operator::OneOf;

## TODO:
# Put all these exports into properly
# segemented export groups, etc.
# For now we can just export everything
# by default, ugly, but fixable later.
# - SL

our @EXPORT;
BEGIN {
    @EXPORT = qw[
        array
        boolean
        null
        number
        object
        schema
        string

        definitions
        dependencies
        enum
        items
        properties
        reference

        allOf
        anyOf
        oneOf
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

sub array        { Paxton::Schema::Type::Array   ->new( @_ ) }
sub boolean      { Paxton::Schema::Type::Boolean ->new( @_ ) }
sub null         { Paxton::Schema::Type::Null    ->new( @_ ) }
sub number       { Paxton::Schema::Type::Number  ->new( @_ ) }
sub object       { Paxton::Schema::Type::Object  ->new( @_ ) }
sub schema       { Paxton::Schema::Type::Schema  ->new( @_ ) }
sub string       { Paxton::Schema::Type::String  ->new( @_ ) }

sub definitions  { Paxton::Schema::Structure::Definitions  ->new( @_ ) }
sub dependencies { Paxton::Schema::Structure::Dependencies ->new( @_ ) }
sub enum         { Paxton::Schema::Structure::Enum         ->new( @_ ) }
sub items        { Paxton::Schema::Structure::Items        ->new( @_ ) }
sub properties   { Paxton::Schema::Structure::Properties   ->new( @_ ) }
sub reference    { Paxton::Schema::Structure::Reference    ->new( @_ ) }

sub allOf        { Paxton::Schema::Operator::AllOf   ->new( @_ ) }
sub anyOf        { Paxton::Schema::Operator::AnyOf   ->new( @_ ) }
sub oneOf        { Paxton::Schema::Operator::OneOf   ->new( @_ ) }

1;

__END__

=pod

=cut
