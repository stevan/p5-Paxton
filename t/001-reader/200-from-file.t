#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

use Path::Tiny ();

use Paxton::Util::Tokens;

tokens_match(
    (Path::Tiny::path('t/data/001-reader/200-from-file.json')->slurp),
    [
        token( START_ARRAY ),
            token(START_ITEM, 0),
                token( START_OBJECT ),
                    token( START_PROPERTY, '_id' ),
                        token( ADD_STRING, '58d42f8ddcf3b58182a9c5c4' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'index' ),
                        token( ADD_INT, 0 ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'guid' ),
                        token( ADD_STRING, '75647fdd-9a57-4393-847b-ae502acbbe4d' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'isActive' ),
                        token( ADD_FALSE ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'balance' ),
                        token( ADD_STRING, '$3,900.68' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'picture' ),
                        token( ADD_STRING, 'http://placehold.it/32x32' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'age' ),
                        token( ADD_INT, 21 ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'eyeColor' ),
                        token( ADD_STRING, 'blue' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'name' ),
                        token( ADD_STRING, 'Sylvia Potter' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'gender' ),
                        token( ADD_STRING, 'female' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'company' ),
                        token( ADD_STRING, 'DEEPENDS' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'email' ),
                        token( ADD_STRING, 'sylviapotter@deepends.com' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'phone' ),
                        token( ADD_STRING, '+1 (875) 427-3904' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'address' ),
                        token( ADD_STRING, '942 Dekoven Court, Gratton, Arizona, 6192' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'about' ),
                        token( ADD_STRING, "Ex nulla ut consectetur ex fugiat non consectetur pariatur non veniam amet. Non cillum tempor voluptate voluptate et esse. Ullamco eu officia ullamco aute Lorem. Aute ex eu id labore mollit est mollit pariatur do cupidatat voluptate et elit dolore. Qui ad ullamco tempor adipisicing et adipisicing anim anim adipisicing veniam non.\r\n" ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'registered' ),
                        token( ADD_STRING, '2015-11-26T02:53:20 -01:00' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'latitude' ),
                        token( ADD_FLOAT, 39.970685 ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'longitude' ),
                        token( ADD_FLOAT, 48.048427 ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'tags' ),
                        token( START_ARRAY ),
                            token(START_ITEM, 0),
                                token( ADD_STRING, 'esse' ),
                            token(END_ITEM),
                            token(START_ITEM, 1),
                                token( ADD_STRING, 'ut' ),
                            token(END_ITEM),
                            token(START_ITEM, 2),
                                token( ADD_STRING, 'anim' ),
                            token(END_ITEM),
                            token(START_ITEM, 3),
                                token( ADD_STRING, 'laboris' ),
                            token(END_ITEM),
                            token(START_ITEM, 4),
                                token( ADD_STRING, 'sit' ),
                            token(END_ITEM),
                            token(START_ITEM, 5),
                                token( ADD_STRING, 'officia' ),
                            token(END_ITEM),
                            token(START_ITEM, 6),
                                token( ADD_STRING, 'ullamco' ),
                            token(END_ITEM),
                        token( END_ARRAY ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'friends' ),
                        token( START_ARRAY ),
                            token(START_ITEM, 0),
                                token( START_OBJECT ),
                                    token( START_PROPERTY, 'id' ),
                                        token( ADD_INT, 0 ),
                                    token( END_PROPERTY ),
                                    token( START_PROPERTY, 'name' ),
                                        token( ADD_STRING, 'Mathews Atkinson' ),
                                    token( END_PROPERTY ),
                                token( END_OBJECT ),
                            token(END_ITEM),
                            token(START_ITEM, 1),
                                token( START_OBJECT ),
                                    token( START_PROPERTY, 'id' ),
                                        token( ADD_INT, 1 ),
                                    token( END_PROPERTY ),
                                    token( START_PROPERTY, 'name' ),
                                        token( ADD_STRING, 'Valdez Mcbride' ),
                                    token( END_PROPERTY ),
                                token( END_OBJECT ),
                            token(END_ITEM),
                            token(START_ITEM, 2),
                                token( START_OBJECT ),
                                    token( START_PROPERTY, 'id' ),
                                        token( ADD_INT, 2 ),
                                    token( END_PROPERTY ),
                                    token( START_PROPERTY, 'name' ),
                                        token( ADD_STRING, 'Baker Burke' ),
                                    token( END_PROPERTY ),
                                token( END_OBJECT ),
                            token(END_ITEM),
                        token( END_ARRAY ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'greeting' ),
                        token( ADD_STRING, 'Hello, Sylvia Potter! You have 5 unread messages.' ),
                    token( END_PROPERTY ),
                    token( START_PROPERTY, 'favoriteFruit' ),
                        token( ADD_STRING, 'banana' ),
                    token( END_PROPERTY ),
                token( END_OBJECT ),
            token(END_ITEM),
        token( END_ARRAY )
    ],
    '... the tokens match!'
);

done_testing;

=pod

This will pretty print the tokens and give you output that
is suitable for building the C<@expected> array above.

    my $r = Paxton::Streaming::IO::Reader->new_from_handle(
        IO::File->new( 't/data/001-reader/200-from-file.json', 'r')
    );

    my $depth = 0;
    while ( my $t = $r->produce_token ) {
        $depth-- if is_struct_end( $t );
        my $indent = ('    ' x $depth);
        print $indent, $t->to_string, ",\n";
        $depth++ if is_struct_start( $t );
    }
=cut

