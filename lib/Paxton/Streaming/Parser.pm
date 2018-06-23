package Paxton::Streaming::Parser;
# ABSTRACT: Convert a stream of tokens into a Paxton::Core::TreeNode tree
use strict;
use warnings;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;
use Paxton::Core::TreeNode;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_PARSER_DEBUG} // 0;

use decorators ':constructor', ':accessors';

our %TOKEN_TYPE_TO_NODE_TYPE = (
    ADD_STRING => Paxton::Core::TreeNode->STRING,
    ADD_INT    => Paxton::Core::TreeNode->INT,
    ADD_FLOAT  => Paxton::Core::TreeNode->FLOAT,
    ADD_TRUE   => Paxton::Core::TreeNode->TRUE,
    ADD_FALSE  => Paxton::Core::TreeNode->FALSE,
    ADD_NULL   => Paxton::Core::TreeNode->NULL,
);

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Consumer';
use slots (
    _context => sub { Paxton::Core::Context->new },
    _value   => sub {},
);

# constructor

sub BUILDARGS : strict( context? => '_context' );

sub BUILD {
    my ($self) = @_;

    $self->{_context}->enter_root_context;
}

# accessors

sub context : ro(_);

sub has_value : predicate(_);
sub get_value : ro(_);

# ...

sub is_full {
    my ($self) = @_;

    $self->has_value
        &&
    $self->{_context}->in_root_context;
}

sub consume_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || throw('Parser is full, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $context    = $self->{_context};
    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('>>> TOKEN:   ', $token->to_string) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, @$context) if DEBUG;
    $self->log('    VALUE:   ', Data::Dumper::Dumper($self->{_value}) =~ s/\n$//r) if DEBUG; #/
    $self->log('    STATE:   ', join ' | ' => grep defined, map $_->[1], @$context) if DEBUG;
    $self->log('         :   ', join ' | ' => map Data::Dumper::Dumper($_->[1])=~s/\n$//r, @$context) if DEBUG; #/

    if ( $token_type == START_OBJECT ) {
        $context->enter_object_context(
            Paxton::Core::TreeNode->new(
                type => Paxton::Core::TreeNode->OBJECT
            )
        );
    }
    elsif ( $token_type == START_PROPERTY ) {
        $context->enter_property_context(
            Paxton::Core::TreeNode->new(
                type  => Paxton::Core::TreeNode->PROPERTY,
                value => $token->value,
            )
        );
    }
    elsif ( $token_type == START_ARRAY ) {
        $context->enter_array_context(
            Paxton::Core::TreeNode->new(
                type => Paxton::Core::TreeNode->ARRAY
            )
        );
    }
    elsif ( $token_type == START_ITEM ) {
        $context->enter_item_context(
            Paxton::Core::TreeNode->new(
                type  => Paxton::Core::TreeNode->ITEM,
                value => $token->value,
            )
        );
    }
    elsif ( is_struct_end( $token ) || is_element_end( $token ) ) {
        my $child  = $context->current_context_value;
        my $parent = $context->leave_current_context;
        if ( $parent ) {
            push @{ $parent->children } => $child;
        }

        if ( $context->in_root_context ) {
            $self->{_value} = $child;
        }
    }
    elsif ( is_scalar( $token ) ) {
        push @{ $context->current_context_value->children } => (
            Paxton::Core::TreeNode->new(
                type  => $TOKEN_TYPE_TO_NODE_TYPE{ $token_type },
                ($token->value) ? (value => $token->value) : (),
            )
        );
    }
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
