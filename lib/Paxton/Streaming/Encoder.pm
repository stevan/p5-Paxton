package Paxton::Streaming::Encoder;
# ABSTRACT: Convert an in-memory data structure into a stream of tokens
use strict;
use warnings;

use MOP::Method;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_ENCODER_DEBUG} // 0;

use decorators ':constructor', ':accessors';

use parent 'UNIVERSAL::Object';
use roles 'Paxton::Streaming::API::Producer';
use slots (
    _source     => sub { die 'You must specify a `source` to encode.'},
    _next_state => sub { \&root },
    _context    => sub { Paxton::Core::Context->new },
    _done       => sub { 0 },
);

## constructor

sub BUILDARGS : strict(
    source      => '_source',
    next_state? => '_next_state',
    context?    => '_context',
);

sub BUILD {
    my ($self) = @_;
    # initialize the state ...
    $self->{_context}->enter_root_context( [ undef, $self->{_source}, [] ] );
}

# ...

sub is_exhausted : ro(_done);

sub _has_no_available_next_state { ! exists $_[0]->{_next_state} }
sub _advance_to_next_state       {   delete $_[0]->{_next_state} }

sub produce_token {
    my ($self) = @_;

    return if $self->{_done};

    if ( my $next = $self->_advance_to_next_state ) {

        my (undef, $data, $state) = @{ $self->{_context}->current_context_value };

        require Data::Dumper if DEBUG;
        $self->log( '>> CURRENT => ', MOP::Method->new( $next )->name) if DEBUG;
        $self->log( '   CONTEXT => ', join ', ' => map $_->{type}, @{ $self->{_context} }) if DEBUG;
        $self->log( '   DATA    => ', Data::Dumper::Dumper( $data )  =~ s/\n$//r ) if DEBUG; #/
        $self->log( '   STATE   => ', Data::Dumper::Dumper( $state ) =~ s/\n$//r ) if DEBUG; #/

        my $token = $self->$next();

        (defined $token && is_token( $token ))
            || throw('Invalid token ('.$token.')' );

        return if $token->type == NO_TOKEN;

        if ( is_error( $token ) ) {
            $self->log( 'Encountered error: ', $token->value ) if DEBUG;
        }
        elsif ( $self->{_context}->in_root_context ) {
            # if we are back into root context
            # that pretty much means we are done
            # so we can do this ...
            $self->{_done} = 1;
        }
        elsif ( $self->_has_no_available_next_state ) {
            throw('Next state is not specified after '.$token->to_string );

        }
        else {
            $self->log( '<< NEXT <= ', $self->{_next_state} ? MOP::Method->new( $self->{_next_state} )->name : 'NONE' ) if DEBUG;
        }

        return $token;
    }

    return;
}

# ...

sub root {
    my ($self) = @_;

    $self->log( 'Entering `root`' ) if DEBUG;

    my (undef, $data, undef) = @{ $self->{_context}->current_context_value };

    if ( my $token = $self->start ) {
        return $token;
    }
    else {
        return $self->end;
    }
}

sub start {
    my ($self) = @_;

    $self->log( 'Entering `start`' ) if DEBUG;

    my (undef, $data, undef) = @{ $self->{_context}->current_context_value };

    return $self->_dispatch_on_type( $data );
}

sub end {
    my ($self) = @_;

    $self->log( 'Entering `end`' ) if DEBUG;

    # NOTE:
    # this token type works for
    # now, but we might want to
    # be more specific later.
    # - SL
    return token( NO_TOKEN );
}

sub object {
    my ($self) = @_;

    $self->log( 'Entering `object`' ) if DEBUG;

    my (undef, $data, $state) = @{ $self->{_context}->current_context_value };

    if ( scalar @$state ) {
        return $self->property;
    }
    else {
        return $self->end_property
            if $self->{_context}->in_property_context;

        $self->{_next_state} = $self->{_context}->leave_object_context->[0];
        return token( END_OBJECT );
    }
}

sub property {
    my ($self) = @_;

    $self->log( 'Entering `property`' ) if DEBUG;

    my (undef, $data, $state) = @{ $self->{_context}->current_context_value };

    if ( not $self->{_context}->in_property_context ) {
        my $key = shift @$state;

        # if we have no keys, just
        # return back to object ...
        return $self->object if not defined $key;

        $self->{_context}->enter_property_context( [ \&end_property, $data->{ $key }, [] ] );
        $self->{_next_state} = \&property;
        return token( START_PROPERTY, $key );
    }
    else {
        my $value = $self->_dispatch_on_type( $data );

        return $value if is_error( $value );

        $self->{_next_state} ||= \&end_property;

        return $value;
    }
}

sub end_property {
    my ($self) = @_;

    $self->log( 'Entering `end_property`' ) if DEBUG;

    $self->{_context}->leave_property_context;
    $self->{_next_state} = \&object;
    return token( END_PROPERTY );
}

sub array {
    my ($self) = @_;

    $self->log( 'Entering `array`' ) if DEBUG;

    my (undef, $data, $state) = @{ $self->{_context}->current_context_value };

    if ( scalar @$state ) {
        return $self->item;
    }
    else {
        return $self->end_item
            if $self->{_context}->in_item_context;

        $self->{_next_state} = $self->{_context}->leave_array_context->[0];
        return token( END_ARRAY );
    }
}

sub item {
    my ($self) = @_;

    $self->log( 'Entering `item`' ) if DEBUG;

    my (undef, $data, $state) = @{ $self->{_context}->current_context_value };

    if ( not $self->{_context}->in_item_context ) {
        my $idx = shift @$state;

        # if we have no indicies, just
        # return back to array ...
        return $self->array if not defined $idx;

        $self->{_context}->enter_item_context( [ \&end_item, $data->[ $idx ], [] ] );
        $self->{_next_state} = \&item;
        return token( START_ITEM, $idx );
    }
    else {
        my $value = $self->_dispatch_on_type( $data );

        return $value if is_error( $value );

        $self->{_next_state} ||= \&end_item;

        return $value;
    }
}

sub end_item {
    my ($self) = @_;

    $self->log( 'Entering `end_item`' ) if DEBUG;

    $self->{_context}->leave_item_context;
    $self->{_next_state} = \&array;
    return token( END_ITEM );
}

sub _dispatch_on_type {
    my ($self, $data) = @_;
    $self->log( 'Entering `_dispatch_on_type`' ) if DEBUG;

    if ( ref $data eq 'HASH' ) {
        $self->{_context}->enter_object_context( [ \&object, $data, [ sort keys $data->%* ] ] );
        $self->{_next_state} = \&property;
        return token( START_OBJECT );
    }
    elsif ( ref $data eq 'ARRAY' ) {
        $self->{_context}->enter_array_context( [ \&array, $data, [ 0 .. $#{$data} ] ] );
        $self->{_next_state} = \&item;
        return token( START_ARRAY );
    }
    elsif ( not defined $data ) {
        return token( ADD_NULL );
    }
    elsif ( ref $data eq 'SCALAR' ) {
        if ( $$data ) {
            return token( ADD_TRUE );
        }
        else {
            return token( ADD_FALSE );
        }
    }
    elsif ( Scalar::Util::looks_like_number( $data ) ) {
        if ( $data =~ /\./ ) {
            return token( ADD_FLOAT, $data );
        }
        else {
            return token( ADD_INT, $data );
        }
    }
    elsif ( ref $data ) {
        # catch some random errors before
        # we just say "f-it, it is a string"
        return token( ERROR, 'Do not recognize the data type (' . $data . ')');
    }
    else {
        return token( ADD_STRING, $data );
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
