package Paxton::Streaming::Parser;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::Core::API::Writer;

use Paxton::Core::Exception;
use Paxton::Core::Tokens;
use Paxton::Core::Context;

use Paxton::Streaming::Parser::Node;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_PARSER_DEBUG} // 0;

# ...

our %TOKEN_TYPE_TO_NODE_TYPE = (
    ADD_STRING => Paxton::Streaming::Parser::Node->STRING,
    ADD_INT    => Paxton::Streaming::Parser::Node->INT,
    ADD_FLOAT  => Paxton::Streaming::Parser::Node->FLOAT,
    ADD_TRUE   => Paxton::Streaming::Parser::Node->TRUE,
    ADD_FALSE  => Paxton::Streaming::Parser::Node->FALSE,
    ADD_NULL   => Paxton::Streaming::Parser::Node->NULL,
);

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::Core::API::Writer') }
our %HAS;  BEGIN {
    %HAS = (
        context => sub { Paxton::Core::Context->new },
        # private
        _value  => sub {},
    )
}

# ...

sub BUILD {
    $_[0]->{context}->enter_root_context;
}

# accessors

sub context { $_[0]->{context} }

sub has_value { defined $_[0]->{_value} }
sub get_value {         $_[0]->{_value} }

# ...

sub is_done {
    my ($self) = @_;
    $self->has_value
        &&
    $self->{context}->in_root_context;
}

sub put_token {
    my ($self, $token) = @_;

    (not $self->is_done)
        || Paxton::Core::Exception->new( message => 'Parser is done, cannot `put` any more tokens' )->throw;

    (defined $token && is_token($token))
        || Paxton::Core::Exception->new( message => 'Invalid token: '.$token )->throw;

    my $context    = $self->{context};
    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('>>> TOKEN:   ', $token->as_string                                  ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->[0], @$context                ) if DEBUG;
    $self->log('    VALUE:   ', Data::Dumper::Dumper($self->{_value})   =~ s/\n$//r) if DEBUG;
    $self->log('    STATE:   ', join ' | ' => grep defined, map $_->[1], @$context) if DEBUG;
    $self->log('         :   ', join ' | ' => map Data::Dumper::Dumper($_->[1])=~s/\n$//r, @$context) if DEBUG;

    if ( $token_type == START_OBJECT ) {
        $context->enter_object_context(
            Paxton::Streaming::Parser::Node->new(
                type => Paxton::Streaming::Parser::Node->OBJECT
            )
        );
    }
    elsif ( $token_type == START_PROPERTY ) {
        $context->enter_property_context(
            Paxton::Streaming::Parser::Node->new(
                type  => Paxton::Streaming::Parser::Node->PROPERTY,
                value => $token->value,
            )
        );
    }
    elsif ( $token_type == START_ARRAY ) {
        $context->enter_array_context(
            Paxton::Streaming::Parser::Node->new(
                type => Paxton::Streaming::Parser::Node->ARRAY
            )
        );
    }
    elsif ( is_struct_end( $token ) ) {
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
            Paxton::Streaming::Parser::Node->new(
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
