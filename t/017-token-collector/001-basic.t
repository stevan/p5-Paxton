#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::TokenIterator');
    use_ok('Paxton::Streaming::TokenCollector');
    use_ok('Paxton::Util::Tokens');
}

subtest '... object iterator' => sub {

    my @tokens = (
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(ADD_STRING, "bar"),
            token(END_PROPERTY),
            token(START_PROPERTY, "baz"),
                token(ADD_STRING, "gorch"),
            token(END_PROPERTY),
        token(END_OBJECT),
    );

    my $ti = Paxton::Streaming::TokenIterator->new( tokens => \@tokens );
    isa_ok($ti, 'Paxton::Streaming::TokenIterator');

    my $tc = Paxton::Streaming::TokenCollector->new;
    isa_ok($tc, 'Paxton::Streaming::TokenCollector');

    $tc->consume( $ti );

    my @sink = $tc->sink->@*;

    foreach my $i ( 0 .. $#tokens ) {
        is($tokens[ $i ], $sink[ $i ], '... got the matching tokens');
    }
};


subtest '... array iterator' => sub {

    my @tokens = (
        token(START_ARRAY),
            token(START_ITEM, 0),
                token(ADD_STRING, "bar"),
            token(END_ITEM),
            token(START_ITEM, 1),
                token(ADD_STRING, "gorch"),
            token(END_ITEM),
            token(START_ITEM, 2),
                token(ADD_INT, 10),
            token(END_ITEM),
            token(START_ITEM, 3),
                token(ADD_FLOAT, 5.5),
            token(END_ITEM),
        token(END_ARRAY)
    );

    my $ti = Paxton::Streaming::TokenIterator->new( tokens => \@tokens );
    isa_ok($ti, 'Paxton::Streaming::TokenIterator');

    my $tc = Paxton::Streaming::TokenCollector->new;
    isa_ok($tc, 'Paxton::Streaming::TokenCollector');

    $tc->consume( $ti );

    my @sink = $tc->sink->@*;

    foreach my $i ( 0 .. $#tokens ) {
        is($tokens[ $i ], $sink[ $i ], '... got the matching tokens');
    }
};


done_testing;
