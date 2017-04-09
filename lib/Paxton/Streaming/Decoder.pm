package Paxton::Streaming::Decoder;
# ABSTRACT: Convert a stream of tokens into an in-memory data structure

use strict;
use warnings;

use UNIVERSAL::Object;

use Paxton::API::Token::Consumer;

use Paxton::Core::Exception;
use Paxton::Util::Tokens;
use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_DECODER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::API::Token::Consumer') }
our %HAS;  BEGIN {
    %HAS = (
        context => sub { Paxton::Core::Context->new },
        # private
        _partial => sub {},
        _value   => sub {},
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

sub is_full {
    my ($self) = @_;
    $self->has_value
        &&
    $self->{context}->in_root_context;
}

sub put_token {
    my ($self, $token) = @_;

    (not $self->is_full)
        || Paxton::Core::Exception->new( message => 'Decoder is done, cannot `put` any more tokens' )->throw;

    (defined $token && is_token($token))
        || Paxton::Core::Exception->new( message => 'Invalid token: '.$token )->throw;

    my $context    = $self->{context};
    my $token_type = $token->type;

    require Data::Dumper if DEBUG;
    $self->log('>>> TOKEN:   ', $token->as_string                                  ) if DEBUG;
    $self->log('    CONTEXT: ', join ', ' => map $_->[0], @$context                ) if DEBUG;
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
    elsif ( is_scalar( $token ) ) {
        my $value = $token->value;
        $value = 1     if $token_type == ADD_TRUE;
        $value = 0     if $token_type == ADD_FALSE;
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
    $_[0]->{context}->in_array_context
        ? (push @{ $_[0]->{context}->current_context_value } => $_[1])
        : $_[0]->{context}->in_root_context
            ? ($_[0]->{_value}   = $_[1])
            : ($_[0]->{_partial} = $_[1])
}


1;

__END__

=pod

=cut
