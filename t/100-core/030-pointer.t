#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('Paxton::Core::Pointer');
}

subtest '... testing simple pointer' => sub {

    my $p = Paxton::Core::Pointer->new( path => '/foo/bar' );
    isa_ok($p, 'Paxton::Core::Pointer');

    is($p->path, '/foo/bar', '... got the expected path back');

    is_deeply(
        [ $p->path_segments ],
        [ 'foo', 'bar' ],
        '... got the expected path segments back'
    );

};

subtest '... testing simple pointer (again)' => sub {

    my $p = Paxton::Core::Pointer->new( '/foo/bar' );
    isa_ok($p, 'Paxton::Core::Pointer');

    is($p->path, '/foo/bar', '... got the expected path back');

    is_deeply(
        [ $p->path_segments ],
        [ 'foo', 'bar' ],
        '... got the expected path segments back'
    );

};


subtest '... testing simple pointer' => sub {

    like(
        exception { Paxton::Core::Pointer->new( path => 'foo/bar' ) },
        qr/Pointer path must start with a \`\/\`/,
        '... got the expected error'
    );

};

done_testing;


