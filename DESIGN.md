# NOTES:

- https://github.com/golang/go/issues/6050#issuecomment-69850788

# Training data ...

- http://jsonstudio.com/resources/


# Paxton

A JSON Framework for Perl

## Components

### I/O

#### JSON Streaming Reader

A low-level, streaming reader API for JSON.

#### JSON Streaming Writer

A low-level, streaming writer API for JSON.

### Models

#### JSON Mapper

Mapping of JSON structures to objects.

#### JSON Schema

Model for representing JSON schemas.

http://json-schema.org/latest/json-schema-core.html

use this to test -> Test::JSON::Schema::Acceptance

#### JSON Patch

Model for JSON patches.

https://tools.ietf.org/html/rfc6902

### Standards

#### JSON Path

JSON Path expressions on a JSON stream.

http://goessner.net/articles/JsonPath/

#### JSON Pointer

JSON pointer matching on a JSON stream.

https://tools.ietf.org/html/rfc6901

#### JSON Patcher

JSON patchs applied to JSON streams

https://tools.ietf.org/html/rfc6902

#### JSON Schema Validation

JSON schema validation on JSON streams.

http://json-schema.org/latest/json-schema-validation.html

## Use Cases

### Query + Inflate

JSON path expressions can be used to match structures
that you want to map into object.

### Address + Inflate

JSON Pointer expression can be used to address a single
structure and then map it into an object.

### Schema => Validate + Inflate

Given a JSON stream, attempt to extract a
substructure conforming to a schema, validating the
input on the way in. A specific example would be an
object schema, if the all the required properties
do not exist, then the match failed, but if the
properties exists it should validate against the
sub-schema, or we have a validation fail.

## See Also

https://google.github.io/styleguide/jsoncstyleguide.xml





