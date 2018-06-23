package Paxton::Streaming::Matcher;
# ABSTRACT: Convert a stream of tokens into a substream containing only tokens relevant to a match criteria.
use strict;
use warnings;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;
use Paxton::Core::Pointer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor', ':accessors';

use constant DEBUG => $ENV{PAXTON_MATCHER_DEBUG} // 0;

# ...

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Consumer';
use slots (
    _pointer        => sub { die 'You must specify a `pointer` to match with' },
    _context        => sub { Paxton::Core::Context->new },
    _done           => sub { 0 },
    _buffer         => sub { +[] },
    _match_context  => sub { undef },
    _pointer_tokens => sub { +[] },
);

# constructor

sub BUILDARGS : strict(
    pointer  => '_pointer',
    context? => '_context',
);

sub BUILD {
    my ($self) = @_;
    $self->{_pointer_tokens} = [ $self->{_pointer}->tokenize ];
    $self->{_context}->enter_root_context;
}

# accessors

sub pointer : ro(_);
sub context : ro(_);

# ...

sub get_matched_tokens {
    my ($self) = @_;

    ($self->is_full)
        || throw('Cannot get matched tokens until matcher is full' );

    @{ $self->{_buffer} };
}

## fullfil the APIs

sub is_full : ro(_done);

sub consume_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || throw('Matcher is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.($token//'undef') );

    my $context    = $self->{_context};
    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('========================================================') if DEBUG;
    $self->log('>>> TOKEN:     ', $token->to_string                      ) if DEBUG;
    $self->log('    CONTEXT:   ', join ', ' => map $_->{type}, @$context ) if DEBUG;
    $self->log('    CTX-DEPTH: ', $context->depth                        ) if DEBUG;
    $self->log('    POINTER:   ', join ', ' => map { '[' . (join ', ' => @{$_}) . ']' } @{ $self->{_pointer_tokens} } ) if DEBUG;
    $self->log('    MATCH-CTX: ', (defined $self->{_match_context} ? $self->{_match_context} : 'undef')) if DEBUG;
    $self->log('    BUFFER:    ', join ', ' => map $_->to_string, @{ $self->{_buffer} }) if DEBUG;
    $self->log('--------------------------------------------------------') if DEBUG;

    my $current_ptr_token = $self->{_pointer_tokens}->[0];
    $self->log('Attempting to match '.$token->to_string.' to ['.(join ', ',@{ $current_ptr_token // [] }).']') if DEBUG;

    my $num_segments_matched = $self->{_pointer}->length - scalar @{ $self->{_pointer_tokens} };
    $self->log('We have matched ' . $num_segments_matched . ' segments so far') if DEBUG;

    my $max_depth = (($num_segments_matched + 1) * 2);

    if ( $token_type == START_OBJECT ) {
        $context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        $context->leave_object_context;
    }
    elsif ( $token_type == START_PROPERTY ) {
        # If we do not already have a match in progress
        # and the depth is  (meaning that we
        # have missed our opportunity for an initial
        # match) then attempt to match ...
        $self->log('... looking for a PROPERTY match') if DEBUG;
        if ( not(defined $self->{_match_context}) && $context->depth == $max_depth ) {
            if (
                $current_ptr_token->[0] == $self->{_pointer}->PROPERTY
                    &&
                $token->value eq $current_ptr_token->[1]
            ) {
                $self->log('Found match with ['.(join', ',@{$current_ptr_token}).']') if DEBUG;
                shift @{ $self->{_pointer_tokens} };
            }
        }
        # now we can enter out next level context ...
        $context->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        $context->leave_property_context;
    }
    elsif ( $token_type == START_ARRAY ) {
        $context->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        $context->leave_array_context;
    }
    elsif ( $token_type == START_ITEM ) {

        $self->log('... looking for an ITEM match') if DEBUG;
        if ( not(defined $self->{_match_context}) && $context->depth == $max_depth ) {
            if (
                $current_ptr_token->[0] == $self->{_pointer}->ITEM
                    &&
                $token->value == $current_ptr_token->[1]
            ) {
                $self->log('Found match with ['.(join', ',@{$current_ptr_token}).']') if DEBUG;
                shift @{ $self->{_pointer_tokens} };
            }
        }
        # now we can enter out next level context ...
        $context->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        $context->leave_item_context;
    }

    # if we are match context ...
    if ( defined $self->{_match_context} ) {
        $self->log('>>> We are in match context ...') if DEBUG;
        # check to see if the depth is
        # greater than our match context
        # depth, ...
        if ( $context->depth <= $self->{_match_context} ) {
            $self->log('!!! Match context is over now') if DEBUG;
            # if however the context depth is
            # less than or equal to the match
            # context, then it is time to leave
            # the match context
            $self->{_match_context} = undef;
            # but grab the last one ...
            push @{ $self->{_buffer} } => $token;
            # and mark it as done ...
            $self->{_done} = 1;
        }
        else {
            $self->log('... Still capturing') if DEBUG;
            # because that means that we are
            # still the process of capturing
            # the tokens
            push @{ $self->{_buffer} } => $token;
        }
    }
    else {
        # if not in match context, (_match_context is `undef`)
        # and if the pointer path has been exhausted, then
        # we have succesfully matched
        if ( scalar @{ $self->{_pointer_tokens} } == 0 ) {
            $self->log('--------------------------------------------------------') if DEBUG;
            $self->log('>>> The Pointer has been matched!') if DEBUG;
            # so we enter match context and
            $self->{_match_context} = $context->depth;
            $self->log('!!!! match context is now: '.$self->{_match_context}) if DEBUG;
            $self->log('--------------------------------------------------------') if DEBUG;
        }
    }

    return;
}

# logging

sub log {
    my ($self, @msg) = @_;
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

1;

__END__

=pod

=cut
