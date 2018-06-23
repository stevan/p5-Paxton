package Paxton::Streaming::Decoder;
# ABSTRACT: Convert a stream of tokens into an in-memory data structure
use strict;
use warnings;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor', ':accessors';

use constant DEBUG => $ENV{PAXTON_DECODER_DEBUG} // 0;

# NOTE:
# we need a way of disambiguating
# between storing `undef` and not
# having a value stored yet, this
# is a marker to tell us no value
# has been set yet.
use constant NO_VALUE => \undef;

# ...

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Consumer';
use slots (
    _context => sub { Paxton::Core::Context->new },
    _partial => sub {},
    _value   => sub { NO_VALUE },
);

# constructor

sub BUILDARGS : strict( context? => '_context' );

sub BUILD {
    my ($self) = @_;
    $self->{_context}->enter_root_context;
}

# accessors

sub context   : ro(_);
sub get_value : ro(_);
sub has_value {
    my ($self) = @_;
    not( ref $self->{_value} &&  $self->{_value} == NO_VALUE )
}

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
        || throw('Decoder is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('>>> TOKEN:   ', $token->to_string                                   ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, @{ $self->{_context} } ) if DEBUG;
    $self->log('    PARTIAL: ', Data::Dumper::Dumper($self->{_partial}) =~ s/\n$//r) if DEBUG; #/
    $self->log('    VALUE:   ', Data::Dumper::Dumper($self->{_value})   =~ s/\n$//r) if DEBUG; #/
    $self->log('    STATE:   ', join ' | ' => grep defined, map $_->[1], @{ $self->{_context} }) if DEBUG;
    $self->log('    STATE:   ', join ' | ' => map Data::Dumper::Dumper($_->[1])=~s/\n$//r, @{ $self->{_context} }) if DEBUG; #/

    if ( $token_type == START_OBJECT ) {
        $self->{_context}->enter_object_context({});
    }
    elsif ( $token_type == END_OBJECT ) {
        my $obj = $self->{_context}->current_context_value;
        $self->{_context}->leave_object_context;
        $self->_stash_value_correctly($obj);
    }

    elsif ( $token_type == START_PROPERTY ) {
        $self->{_context}->enter_property_context( $token->value );
    }
    elsif ( $token_type == END_PROPERTY ) {
        my $key = $self->{_context}->current_context_value;
        my $obj = $self->{_context}->leave_property_context;
        $obj->{ $key } = $self->{_partial};
    }

    elsif ( $token_type == START_ARRAY ) {
        $self->{_context}->enter_array_context([]);
    }
    elsif ( $token_type == END_ARRAY ) {
        my $array = $self->{_context}->current_context_value;
        $self->{_context}->leave_array_context;
        $self->_stash_value_correctly($array);
    }

    elsif ( $token_type == START_ITEM ) {
        $self->{_context}->enter_item_context( $token->value );
    }
    elsif ( $token_type == END_ITEM ) {
        my $idx = $self->{_context}->current_context_value;
        my $arr = $self->{_context}->leave_item_context;
        $arr->[ $idx ] = $self->{_partial};
    }

    elsif ( is_scalar( $token ) ) {
        my $value = $token->value;
        $value = \1    if $token_type == ADD_TRUE;
        $value = \0    if $token_type == ADD_FALSE;
        $value = undef if $token_type == ADD_NULL;
        $self->_stash_value_correctly( $value )
    }
}

# logging

sub log {
    my ($self, @msg) = @_;

    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# ...

sub _stash_value_correctly {
    my ($self, $value) = @_;
    $self->{_context}->in_array_context
        ? (push @{ $self->{_context}->current_context_value } => $value)
        : $self->{_context}->in_root_context
            ? ($self->{_value}   = $value)
            : ($self->{_partial} = $value)
}

1;

__END__

=pod

=cut
