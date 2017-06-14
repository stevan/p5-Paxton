#!perl

use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('Paxton::Streaming::TokenIterator');
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

    my $ctx = $ti->context;
    isa_ok($ctx, 'Paxton::Core::Context');

    my @stack;
    $ctx->bind_event( '_' => sub { push @stack => $_[1] } );

    ok(!$ti->is_exhausted, '... we are not exhausted yet');
    ok($ctx->in_root_context, '... we are in the expected context');

    # START_OBJECT
    is($ti->produce_token, $tokens[0], '... got the matching token (START_OBJECT)');
    ok($ctx->in_object_context, '... we are in the expected context');
    is($stack[-1], 'enter_object_context', '... got the expected context event');

    # START_PROPERTY
    is($ti->produce_token, $tokens[1], '... got the matching token (START_PROPERTY)');
    ok($ctx->in_property_context, '... we are in the expected context');
    is($stack[-1], 'enter_property_context', '... got the expected context event');

    # ADD_STRING
    is($ti->produce_token, $tokens[2], '... got the matching token (ADD_STRING)');
    ok($ctx->in_property_context, '... we are (still) in the expected context');
    is($stack[-1], 'enter_property_context', '... got the expected context event');

    # END_PROPERTY
    is($ti->produce_token, $tokens[3], '... got the matching token (END_PROPERTY)');
    ok($ctx->in_object_context, '... we are back in the object context');
    is($stack[-1], 'leave_property_context', '... got the expected context event');

    # START_PROPERTY
    is($ti->produce_token, $tokens[4], '... got the matching token (START_PROPERTY)');
    ok($ctx->in_property_context, '... we are in the expected context');
    is($stack[-1], 'enter_property_context', '... got the expected context event');

    # ADD_STRING
    is($ti->produce_token, $tokens[5], '... got the matching token (ADD_STRING)');
    ok($ctx->in_property_context, '... we are (still) in the expected context');
    is($stack[-1], 'enter_property_context', '... got the expected context event');

    # END_PROPERTY
    is($ti->produce_token, $tokens[6], '... got the matching token (END_PROPERTY)');
    ok($ctx->in_object_context, '... we are back in the object context');
    is($stack[-1], 'leave_property_context', '... got the expected context event');

    # END_OBJECT
    is($ti->produce_token, $tokens[7], '... got the matching token (END_OBJECT)');
    ok($ctx->in_root_context, '... we are in the expected context');
    is($stack[-1], 'leave_object_context', '... got the expected context event');

    ok($ti->is_exhausted, '... we are exhausted now');
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

    my $ctx = $ti->context;
    isa_ok($ctx, 'Paxton::Core::Context');

    my @stack;
    $ctx->bind_event( '*' => sub { push @stack => $_[1] } );

    ok(!$ti->is_exhausted, '... we are not exhausted yet');
    ok($ctx->in_root_context, '... we are in the expected context');

    # START_ARRAY
    is($ti->produce_token, $tokens[0], '... got the matching token (START_ARRAY)');
    ok($ctx->in_array_context, '... we are in the expected context');
    is($stack[-1], 'enter_array_context', '... got the expected context event');

    # START_ITEM
    is($ti->produce_token, $tokens[1], '... got the matching token (START_ITEM)');
    ok($ctx->in_item_context, '... we are in the expected context');
    is($stack[-1], 'enter_item_context', '... got the expected context event');

    # ADD_STRING
    is($ti->produce_token, $tokens[2], '... got the matching token (ADD_STRING)');
    ok($ctx->in_item_context, '... we are (still) in the expected context');

    # END_ITEM
    is($ti->produce_token, $tokens[3], '... got the matching token (END_ITEM)');
    ok($ctx->in_array_context, '... we are back in the object context');
    is($stack[-1], 'leave_item_context', '... got the expected context event');

    # START_ITEM
    is($ti->produce_token, $tokens[4], '... got the matching token (START_ITEM)');
    ok($ctx->in_item_context, '... we are in the expected context');
    is($stack[-1], 'enter_item_context', '... got the expected context event');

    # ADD_STRING
    is($ti->produce_token, $tokens[5], '... got the matching token (ADD_STRING)');
    ok($ctx->in_item_context, '... we are (still) in the expected context');

    # END_ITEM
    is($ti->produce_token, $tokens[6], '... got the matching token (END_ITEM)');
    ok($ctx->in_array_context, '... we are back in the object context');
    is($stack[-1], 'leave_item_context', '... got the expected context event');

    # START_ITEM
    is($ti->produce_token, $tokens[7], '... got the matching token (START_ITEM)');
    ok($ctx->in_item_context, '... we are in the expected context');
    is($stack[-1], 'enter_item_context', '... got the expected context event');

    # ADD_STRING
    is($ti->produce_token, $tokens[8], '... got the matching token (ADD_INT)');
    ok($ctx->in_item_context, '... we are (still) in the expected context');

    # END_ITEM
    is($ti->produce_token, $tokens[9], '... got the matching token (END_ITEM)');
    ok($ctx->in_array_context, '... we are back in the object context');
    is($stack[-1], 'leave_item_context', '... got the expected context event');

    # START_ITEM
    is($ti->produce_token, $tokens[10], '... got the matching token (START_ITEM)');
    ok($ctx->in_item_context, '... we are in the expected context');
    is($stack[-1], 'enter_item_context', '... got the expected context event');

    # ADD_STRING
    is($ti->produce_token, $tokens[11], '... got the matching token (ADD_FLOAT)');
    ok($ctx->in_item_context, '... we are (still) in the expected context');

    # END_ITEM
    is($ti->produce_token, $tokens[12], '... got the matching token (END_ITEM)');
    ok($ctx->in_array_context, '... we are back in the object context');
    is($stack[-1], 'leave_item_context', '... got the expected context event');

    # END_ARRAY
    is($ti->produce_token, $tokens[13], '... got the matching token (END_ARRAY)');
    ok($ctx->in_root_context, '... we are in the expected context');
    is($stack[-1], 'leave_array_context', '... got the expected context event');

    ok($ti->is_exhausted, '... we are exhausted now');
};


done_testing;
