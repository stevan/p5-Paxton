package Jellybean::Schema::JSON::Schema::V4;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Jellybean::Core;
use Jellybean::Util::Syntax;

BEGIN {
    no strict 'refs';
    *{$_} = *{'Jellybean::Core::'.$_}         for @Jellybean::Core::EXPORT_OK;
    *{$_} = *{'Jellybean::Util::Syntax::'.$_} for @Jellybean::Util::Syntax::EXPORT_OK;
}

# This is actually the meta-schema, which is nicely
# described with the schema language itself and
# a little bit of Perl syntax mixed in.

# So, to start, the schema is a package, and we just
# map all of the things that would be in the schema
# into the Perl package in some way.

# Note that the goal is to make the description of a
# schema in Perl feel like Perl, instead of feeling
# like JSON in a Perl HoHoH dialect.

our $ID           = "http://json-schema.org/draft-04/schema#";
our $SCHEMA       = "http://json-schema.org/draft-04/schema#";
our $DESCRIPTION  = "Core schema meta-schema";
our $DEFAULT      = Schema();
our %PROPERTIES   = ();
our %DEFINITIONS  = ();
our %DEPENDENCIES = (
    exclusiveMaximum => [ "maximum" ],
    exclusiveMinimum => [ "minimum" ],
);


# Next, if there are any schemas to be found
# in the definitions area, we will want to
# create new type combinators for them.

def schemaArray             => Array( minItems => 1, items => Ref('#') );
def positiveInteger         => Integer( minimum => 0 );
def positiveIntegerDefault0 => AllOf( Ref('#/definitions/positiveInteger'), Schema( default => 0 ) );
def simpleTypes             => Enum( 'array', 'boolean', 'integer', 'null', 'number', 'object', 'string' );
def stringArray             => Array( items => String, minItems => 1, uniqueItems => true );

# I think we can always assume our type is an object, I am not sure it
# makes any sense to think of it any other way. Most things that are complex
# enough to require a schema are going to be objects.

prop 'id'          => String( format => 'uri' );
prop '$schema'     => String( format => 'uri' );
prop 'title'       => String();
prop 'description' => String();
prop 'default'     => Schema();
prop 'multipleOf'  => Number( minimum => 0, exclusiveMinimum => true );

prop 'maximum'          => Number();
prop 'exclusiveMaximum' => Boolean( default => false );
prop 'minimum'          => Number();
prop 'exclusiveMinimum' => Boolean( default => false );

prop 'maxLength' => Ref('#/definitions/positiveInteger');
prop 'minLength' => Ref('#/definitions/positiveIntegerDefault0');

prop 'pattern' => String( format => 'regex' );

prop 'additionalItems' => Schema(
    default => Schema(),
    anyOf  => [
        Boolean(),
        Ref('#')
    ],
);

prop 'items' => Schema(
    default => Schema(),
    anyOf   => [
        Ref('#'),
        Ref('#/definitions/schemaArray')
    ],
);

prop 'maxItems'    => Ref('#/definitions/positiveInteger');
prop 'minItems'    => Ref('#/definitions/positiveIntegerDefault0');
prop 'uniqueItems' => Boolean( default => false );

prop 'maxProperties'        => Ref('#/definitions/positiveInteger');
prop 'minProperties'        => Ref('#/definitions/positiveIntegerDefault0');
prop 'required'             => Ref('#/definitions/stringArray');
prop 'additionalProperties' => Schema(
    default => Schema(),
    anyOf   => [
        Boolean(),
        Ref('#')
    ]
);

prop 'definitions'       => Object( additionalProperties => Ref('#'), default => Schema() );
prop 'properties'        => Object( additionalProperties => Ref('#'), default => Schema() );
prop 'patternProperties' => Object( additionalProperties => Ref('#'), default => Schema() );
prop 'dependencies'      => Object(
    additionalProperties => AnyOf(
        Ref('#'),
        Ref('#/definitions/stringArray')
    )
);

prop 'enum' => Array( minItems => 1, uniqueItems => true );
prop 'type' => AnyOf(
    Ref('#/definitions/simpleTypes'),
    Array(
        items       => Ref('#/definitions/simpleTypes'),
        minItems    => 1,
        uniqueItems => true,
    )
);
prop 'allOf' => Ref('#/definitions/schemaArray');
prop 'anyOf' => Ref('#/definitions/schemaArray');
prop 'oneOf' => Ref('#/definitions/schemaArray');
prop 'not'   => Ref('#');

1;

__END__

=pod

=cut
