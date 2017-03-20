package Jellybean::Core;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Jellybean::Core::Schema;
use Jellybean::Core::Schema::Ref;

our @EXPORT_OK; BEGIN {
    @EXPORT_OK = qw[
        Ref Schema
        String Integer Number Boolean Object Array Null
        Enum Not AllOf AnyOf OneOf
    ]
}

sub import {
    shift;
    my $pkg     = caller();
    my @exports = @_ ? @_ : @EXPORT_OK;

    no strict 'refs';
    *{$pkg.'::'.$_} = \&{$_} for @exports;
}

# We have some base stuff we need to create ...

sub Ref     ($) { my ($uri)  = @_; Jellybean::Core::Schema::Ref->new( $uri ) }
sub Schema  (%) { my (%args) = @_; Jellybean::Core::Schema->new( %args )     }

# next we start to build our base type combinators ...

sub String  (%) { my (%args) = @_; Schema( type => 'string',  %args ) }
sub Integer (%) { my (%args) = @_; Schema( type => 'integer', %args ) }
sub Number  (%) { my (%args) = @_; Schema( type => 'number',  %args ) }
sub Boolean (%) { my (%args) = @_; Schema( type => 'boolean', %args ) }
sub Object  (%) { my (%args) = @_; Schema( type => 'object',  %args ) }
sub Array   (%) { my (%args) = @_; Schema( type => 'array',   %args ) }
sub Null    (%) { my (%args) = @_; Schema( type => 'null',    %args ) }

# and some of the "instance types"

sub Enum  (@) { my (@items)   = @_; Schema( enum  => \@items   ) }
sub Not   ($) { my ($schema)  = @_; Schema( not   => $schema   ) }
sub AllOf (@) { my (@schemas) = @_; Schema( allOf => \@schemas ) }
sub AnyOf (@) { my (@schemas) = @_; Schema( anyOf => \@schemas ) }
sub OneOf (@) { my (@schemas) = @_; Schema( oneOf => \@schemas ) }

# these types are "open", meaning they
# can be extended, this is shown by the
# fact they allow additional arguments
# to be passed in.

# NOTE:
# we might want to look into clarifying
# the open/closed situation of the type
# by using Method::Traits, not sure it
# it is needed though.

1;

__END__

=pod

=cut
