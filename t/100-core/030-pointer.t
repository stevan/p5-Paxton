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

    is_deeply(
        [ $p->tokenize ],
        [ [ Paxton::Core::Pointer->PROPERTY, 'foo' ], [ Paxton::Core::Pointer->PROPERTY, 'bar' ] ],
        '... got the expected path segments back'
    );

};



subtest '... testing simple pointer (again)' => sub {

    my $p = Paxton::Core::Pointer->new( '/0/bar' );
    isa_ok($p, 'Paxton::Core::Pointer');

    is($p->path, '/0/bar', '... got the expected path back');

    is_deeply(
        [ $p->path_segments ],
        [ '0', 'bar' ],
        '... got the expected path segments back'
    );

    is_deeply(
        [ $p->tokenize ],
        [ [ Paxton::Core::Pointer->ITEM, 0 ], [ Paxton::Core::Pointer->PROPERTY, 'bar' ] ],
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


