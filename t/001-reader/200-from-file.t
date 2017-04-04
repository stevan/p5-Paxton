#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::Reader');
    use_ok('Paxton::Core::Tokens');
}

my $r = Paxton::Streaming::Reader->new_from_stream(
    IO::File->new( 'share/schemas/json-schema-v4.json', 'r')
);

my $depth = 0;
while ( my $t = $r->next_token ) {
    $depth-- if is_struct_end( $t );
    my $indent = ('    ' x $depth);
    print $indent, $t->as_string, ",\n";
    $depth++ if is_struct_start( $t );
}

done_testing;
