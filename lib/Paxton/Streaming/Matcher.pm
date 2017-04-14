package Paxton::Streaming::Matcher;
# ABSTRACT: Consume a stream and fire callback when a JSON Pointer is matched

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::API::Token::Consumer;

use Paxton::Core::Exception;
use Paxton::Util::Tokens;
use Paxton::Core::Context;
use Paxton::Core::Pointer;

use Paxton::Util::TokenIterator;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_MATCHER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::API::Token::Consumer') }
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
        || Paxton::Core::Exception->new( message => 'Cannot get matched tokens until matcher is done' )->throw;
    @{ $self->{_buffer} };
}

sub get_matched_token_iterator {
    my ($self) = @_;
    Paxton::Util::TokenIterator->new( tokens => $self->{_buffer} );
}

## fullfil the APIs

sub is_full {
    my ($self) = @_;
    $self->{_done};
}

sub put_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || Paxton::Core::Exception->new( message => 'Matcher is done, cannot `put` any more tokens' )->throw;

    (defined $token && is_token($token))
        || Paxton::Core::Exception->new( message => 'Invalid token: '.$token )->throw;

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

    if ( $token_type == START_OBJECT ) {
        $context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        $context->leave_object_context;
    }
    elsif ( $token_type == START_PROPERTY ) {
        $context->enter_property_context;

        unless ( $self->{_match_context} ) {

            my $current_ptr_token = $self->{_pointer_tokens}->[0];

            $self->log('Attempting to match '.$token->value.' to ['.(join ', ',@$current_ptr_token).']') if DEBUG;

            if (
                $current_ptr_token->[0] eq $self->{pointer}->PROPERTY
                    &&
                $token->value eq $current_ptr_token->[1]
            ) {
                $self->log('Found match with ['.(join', ',@{$current_ptr_token}).']') if DEBUG;
                shift @{ $self->{_pointer_tokens} };
            }
        }
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
