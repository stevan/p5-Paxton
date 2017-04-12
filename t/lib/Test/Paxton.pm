package Test::Paxton;

use strict;
use warnings;

use Test::More           ();
use Test::Fatal          ('exception');
use Paxton::Util::Tokens ('is_token');

use Paxton::Streaming::Reader;
use Paxton::Streaming::Decoder;
use Paxton::Streaming::Encoder;

## ...

use constant VERBOSE => $ENV{PAXTON_TEST_VERBOSE} // 0;

## ...

our @EXPORT = qw[
    tokens_match
    tokens_decode_into
    tokens_encoded_from
    tokens_written_to
];

## ...

sub import { (shift)->import_into( scalar caller, @_ ) }

sub import_into {
    my (undef, $into, @export) = @_;
    @export = @EXPORT unless @export;
    no strict 'refs';
    *{$into.'::'.$_} = \&{$_} foreach @export;
}

## ...

sub tokens_match {
    my ($json, $expected, $msg) = @_;

    Test::More::subtest( $msg => sub {
        Test::More::diag( $json ) if VERBOSE;

        my $r = Paxton::Streaming::Reader->new_from_string( \$json );
        Test::More::isa_ok($r, 'Paxton::Streaming::Reader');

        foreach my $e ( @$expected ) {
            my $t = $r->get_token;
            Test::More::ok(is_token( $t ), '... we got a token');
            Test::More::is($t->type, $e->type, '... and it is the expected token type('.$e->type.')');
            Test::More::is($t->value, $e->value, '... and it is the expected token value('.($e->value // 'undef').')');
            Test::More::diag( $t->dump ) if VERBOSE;
        }

        Test::More::is( $r->get_token, undef, '... parsing is complete' );
        Test::More::ok( $r->is_exhausted, '... the reader is done' );
    });
}

sub tokens_written_to {
    my ($tokens_to_write, $expected, $msg) = @_;

    Test::More::subtest($msg => sub {
        my $json = '';

        my $w = Paxton::Streaming::Writer->new_to_string( \$json );
        Test::More::isa_ok($w, 'Paxton::Streaming::Writer');

        $w->put_token( $_ ) foreach @$tokens_to_write;

        Test::More::ok(!$w->is_full, '... we are not done yet');
        Test::More::is(exception { $w->close }, undef, '... closed the writer');
        Test::More::ok($w->is_full, '... we are done now');

        Test::More::is($json, $expected, '... got the JSON we expected');
    });
}

sub tokens_decode_into {
    my ($decoded_into, $expected, $msg) = @_;

    Test::More::subtest( $msg => sub {

        my $d = Paxton::Streaming::Decoder->new;
        Test::More::isa_ok($d, 'Paxton::Streaming::Decoder');

        Test::More::ok(!$d->has_value, '... we do not have a value yet');

        $d->put_token( $_ ) foreach @$expected;

        Test::More::ok($d->has_value, '... we have a value now');
        Test::More::is_deeply(
            $d->get_value,
            $decoded_into,
            '... got the expected value'
        );

        Test::More::ok( $d->is_full, '... the decoder is done' );
    });
}

sub tokens_encoded_from {
    my ($source, $tokens, $msg) = @_;

    my @tokens = @$tokens;

    Test::More::subtest( $msg => sub {

        my $e = Paxton::Streaming::Encoder->new( source => $source );
        Test::More::isa_ok($e, 'Paxton::Streaming::Encoder');

        while ( my $got = $e->get_token ) {
            my $expected = shift @tokens;
            Test::More::diag $got->to_string      if VERBOSE;
            Test::More::diag $expected->to_string if VERBOSE;
            Test::More::is_deeply( $got, $expected, '... got the expected token' );
        }

        Test::More::is(scalar(@tokens), 0, '... exhausted all the tokens');
        Test::More::ok($e->is_exhausted, '... the encoder is now done');
    });
}


1;

__END__
