#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;

use Paxton::Streaming::Reader;
use Paxton::Core::Tokens;

my $r = Paxton::Streaming::Reader->new_from_stream(
    IO::File->new( 'share/schemas/json-schema-v4.json', 'r')
);


my $depth = 0;
while ( my $t = $r->next_token ) {
    $depth-- if $t->type == END_OBJECT   || $t->type == END_ARRAY   || $t->type == END_PROPERTY;
    my $indent = ('    ' x $depth);
    print $indent, $t->as_string, ",\n";
    $depth++ if $t->type == START_OBJECT || $t->type == START_ARRAY || $t->type == START_PROPERTY;
}

done_testing;
