package Paxton::Streaming::Matcher;
# ABSTRACT: Convert a stream of tokens into a substream containing only tokens relevant to a match criteria.

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::API::Tokenizer::Consumer;

use Paxton::Core::Exception;
use Paxton::Util::Tokens;
use Paxton::Core::Context;
use Paxton::Core::Pointer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_MATCHER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::API::Tokenizer::Consumer') }
our %HAS;  BEGIN {
    %HAS = (
        pointer => sub { die 'You must specify a `pointer` to match with' },
        context => sub { Paxton::Core::Context->new },
        ## private
        # flags
        _done           => sub { 0 },
        # captured ...
        _buffer         => sub { +[] },
        # matching ...
        _match_context  => sub { undef },
        _pointer_tokens => sub { +[] },
    )
}

# ...

sub BUILD {
    my ($self) = @_;

    $self->{_pointer_tokens} = [ $self->{pointer}->tokenize ];

    $self->{context}->enter_root_context;
}

# accessors

sub pointer { $_[0]->{pointer} }
sub context { $_[0]->{context} }

# ...

sub get_matched_tokens {
    my ($self) = @_;
    ($self->is_full)
        || Paxton::Core::Exception->new( message => 'Cannot get matched tokens until matcher is full' )->throw;
    @{ $self->{_buffer} };
}

## fullfil the APIs

sub is_full {
    my ($self) = @_;
    $self->{_done};
}

sub consume_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || Paxton::Core::Exception->new( message => 'Matcher is done, cannot `put` any more tokens' )->throw;

    (defined $token && is_token($token))
        || Paxton::Core::Exception->new( message => 'Invalid token: '.($token//'undef') )->throw;

    my $context    = $self->{context};
    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('========================================================') if DEBUG;
    $self->log('>>> TOKEN:     ', $token->to_string                      ) if DEBUG;
    $self->log('    CONTEXT:   ', join ', ' => map $_->{type}, @$context ) if DEBUG;
    $self->log('    CTX-DEPTH: ', $context->depth                        ) if DEBUG;
    $self->log('    POINTER:   ', join ', ' => map { '[' . (join ', ' => @{$_}) . ']' } @{$self->{_pointer_tokens}} ) if DEBUG;
    $self->log('    MATCH-CTX: ', (defined $self->{_match_context} ? $self->{_match_context} : 'undef')) if DEBUG;
    $self->log('    BUFFER:    ', join ', ' => map $_->to_string, @{$self->{_buffer}}) if DEBUG;
    $self->log('--------------------------------------------------------') if DEBUG;

    my $current_ptr_token = $self->{_pointer_tokens}->[0];
    $self->log('Attempting to match '.$token->to_string.' to ['.(join ', ',@{ $current_ptr_token // [] }).']') if DEBUG;

    my $num_segments_matched = $self->{pointer}->length - scalar @{$self->{_pointer_tokens}};
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
                $current_ptr_token->[0] == $self->{pointer}->PROPERTY
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
                $current_ptr_token->[0] == $self->{pointer}->ITEM
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
            undef $self->{_match_context};
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

# ROLE COMPOSITON

BEGIN {
    use MOP::Role;
    use MOP::Internal::Util;
    MOP::Internal::Util::APPLY_ROLES(
        MOP::Role->new(name => __PACKAGE__),
        \@DOES,
        to => 'class'
    );
}

1;

__END__

=pod

=cut
