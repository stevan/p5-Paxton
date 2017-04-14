#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Util::TokenIterator');
    use_ok('Paxton::Util::Tokens');

    use_ok('Paxton::Core::Pointer');

    use_ok('Paxton::Streaming::Matcher');
    use_ok('Paxton::Streaming::Decoder');
}

subtest '... basic matcher' => sub {

    my @tokens = (
        token(START_OBJECT),
            token(START_PROPERTY, "foo"),
                token(START_OBJECT),
                    token(START_PROPERTY, "bar"),
                        token(START_OBJECT),
                            token(START_PROPERTY, "baz"),
                                token(ADD_STRING, "gorch"),
                            token(END_PROPERTY),
                        token(END_OBJECT),
                    token(END_PROPERTY),
                token(END_OBJECT),
            token(END_PROPERTY),
        token(END_OBJECT),
    );

    my $in = Paxton::Util::TokenIterator->new( tokens => \@tokens );
    isa_ok($in, 'Paxton::Util::TokenIterator');

    my $ptr = Paxton::Core::Pointer->new( '/foo' );
    isa_ok($ptr, 'Paxton::Core::Pointer');

    my $m = Paxton::Streaming::Matcher->new( pointer => $ptr );
    isa_ok($m, 'Paxton::Streaming::Matcher');

    my $d = Paxton::Streaming::Decoder->new;
    isa_ok($d, 'Paxton::Streaming::Decoder');

    until ( $m->is_full ) {
        $m->put_token( $in->get_token );
    }

    my $out = $m->get_matched_token_iterator;
    isa_ok($out, 'Paxton::Util::TokenIterator');

    until ( $d->is_full ) {
        $d->put_token( $out->get_token );
    }

    is_deeply($d->get_value, { bar => { baz => 'gorch' } }, '... got the expected decoded value');

};


done_testing;
