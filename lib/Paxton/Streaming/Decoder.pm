package Paxton::Streaming::Decoder;
# ABSTRACT: Convert a stream of tokens into an in-memory data structure
use Moxie;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_DECODER_DEBUG} // 0;

# NOTE:
# we need a way of disambiguating
# between storing `undef` and not
# having a value stored yet, this
# is a marker to tell us no value
# has been set yet.
use constant NO_VALUE => \undef;

# ...

extends 'Moxie::Object';
   with 'Paxton::Streaming::API::Consumer';

has 'context'  => sub { Paxton::Core::Context->new };
# private
has '_partial' => sub {};
has '_value'   => sub { NO_VALUE };

# ...

sub BUILD ($self, $) {
    $self->{context}->enter_root_context;
}

# accessors

sub context   : ro;
sub get_value : ro('_value');
sub has_value ($self) {
    not( ref $self->{_value} &&  $self->{_value} == NO_VALUE )
}

# ...

sub is_full ($self) {
    $self->has_value
        &&
    $self->{context}->in_root_context;
}

sub consume_token ($self, $token) {
    (not $self->is_full)
        || throw('Decoder is done, cannot `put` any more tokens' );

    (defined $token && is_token($token))
        || throw('Invalid token: '.$token );

    my $context    = $self->{context};
    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('>>> TOKEN:   ', $token->to_string                                  ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->{type}, @$context                ) if DEBUG;
    $self->log('    PARTIAL: ', Data::Dumper::Dumper($self->{_partial}) =~ s/\n$//r) if DEBUG; #/
    $self->log('    VALUE:   ', Data::Dumper::Dumper($self->{_value})   =~ s/\n$//r) if DEBUG; #/
    $self->log('    STATE:   ', join ' | ' => grep defined, map $_->[1], @$context) if DEBUG;
    $self->log('    STATE:   ', join ' | ' => map Data::Dumper::Dumper($_->[1])=~s/\n$//r, @$context) if DEBUG; #/

    if ( $token_type == START_OBJECT ) {
        $context->enter_object_context({});
    }
    elsif ( $token_type == END_OBJECT ) {
        my $obj = $context->current_context_value;
        $context->leave_object_context;
        $self->_stash_value_correctly($obj);
    }

    elsif ( $token_type == START_PROPERTY ) {
        $context->enter_property_context( $token->value );
    }
    elsif ( $token_type == END_PROPERTY ) {
        my $key = $context->current_context_value;
        my $obj = $context->leave_property_context;
        $obj->{ $key } = $self->{_partial};
    }

    elsif ( $token_type == START_ARRAY ) {
        $context->enter_array_context([]);
    }
    elsif ( $token_type == END_ARRAY ) {
        my $array = $context->current_context_value;
        $context->leave_array_context;
        $self->_stash_value_correctly($array);
    }

    elsif ( $token_type == START_ITEM ) {
        $context->enter_item_context( $token->value );
    }
    elsif ( $token_type == END_ITEM ) {
        my $idx = $context->current_context_value;
        my $arr = $context->leave_item_context;
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

sub log ($self, @msg) {
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# ...

sub _stash_value_correctly ($self, $value) {
    $self->{context}->in_array_context
        ? (push @{ $self->{context}->current_context_value } => $value)
        : $self->{context}->in_root_context
            ? ($self->{_value}   = $value)
            : ($self->{_partial} = $value)
}

1;

__END__

=pod

=cut
