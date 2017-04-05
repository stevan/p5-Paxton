package Test::Paxton;

use strict;
use warnings;

use Test::More           ();
use Paxton::Core::Tokens ('is_token');

use Paxton::Streaming::Reader;

## ...

use constant VERBOSE => $ENV{PAXTON_TEST_VERBOSE} // 0;

## ...

our @EXPORT = qw[
    tokens_match
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
        Test::More::ok( $r->{source}->is_done, '... the reader is done' );
    });
}


1;

__END__
