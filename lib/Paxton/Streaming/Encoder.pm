package Paxton::Streaming::Encoder;
# ABSTRACT: Convert an in-memory data structure into a stream of tokens

use strict;
use warnings;

use UNIVERSAL::Object;
use MOP::Method;

use Paxton::API::Token::Producer;

use Paxton::Core::Exception;
use Paxton::Util::Tokens;
use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_ENCODER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::API::Token::Producer') }
our %HAS;  BEGIN {
    %HAS = (
        source     => sub { die 'You must specify a `source` to encode.'},
        next_state => sub { \&root },
        context    => sub { Paxton::Core::Context->new },
        # private ...
        _done   => sub { 0 },
    )
}

sub BUILD {
    my ($self) = @_;
    # initialize the state ...
    $self->{context}->enter_root_context( [ undef, $self->{source}, [] ] );
}

# ...

sub is_exhausted {
    my ($self) = @_;
    return $self->{_done};
}

sub get_token {
    my ($self) = @_;

    return if $self->{_done};

    if ( my $next = delete $self->{next_state} ) {

        my (undef, $data, $state) = @{ $self->{context}->current_context_value };

        require Data::Dumper if DEBUG;
        $self->log( '>> CURRENT => ', MOP::Method->new( $next )->name                 ) if DEBUG;
        $self->log( '   CONTEXT => ', join ', ' => map $_->[0], @{ $self->{context} } ) if DEBUG;
        $self->log( '   DATA    => ', Data::Dumper::Dumper( $data )  =~ s/\n$//r      ) if DEBUG; #/
        $self->log( '   STATE   => ', Data::Dumper::Dumper( $state ) =~ s/\n$//r      ) if DEBUG; #/

        my $token = $self->$next();

        (defined $token && is_token( $token ))
            || Paxton::Core::Exception->new( message => 'Invalid token ('.$token.')' )->throw;

        return if $token->type == NO_TOKEN;

        if ( is_error( $token ) ) {
            $self->log( 'Encountered error: ', $token->value ) if DEBUG;
        }
        elsif ( not exists $self->{next_state} ) {
            Paxton::Core::Exception
                ->new( message => 'Next state is not specified after '.$token->as_string )
                ->throw;
        }

        $self->log( '<< NEXT <= ', $self->{next_state} ? MOP::Method->new( $self->{next_state} )->name : 'NONE' ) if DEBUG;

        # if we are back into root context
        # that pretty much means we are done
        # so we can do this ...
        if ( $self->{context}->in_root_context ) {
            $self->{_done} = 1;
        }

        return $token;
    }

    return;
}

# ...

sub root {
    my ($self) = @_;

    $self->log( 'Entering `root`' ) if DEBUG;

    my $context = $self->{context};
    my (undef, $data, undef) = @{ $context->current_context_value };

    if ( defined $data ) {
        if ( ref $data eq 'HASH' || ref $data eq 'ARRAY' ) {
            return $self->start;
        }
        else {
            return token( ERROR, 'Root node must be either array or object' );
        }
    }
    else {
        return $self->end;
    }
}

sub start {
    my ($self) = @_;

    $self->log( 'Entering `start`' ) if DEBUG;

    my $context = $self->{context};
    my (undef, $data, undef) = @{ $context->current_context_value };

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

    my $context = $self->{context};
    my (undef, $data, $state) = @{ $context->current_context_value };

    if ( scalar @$state ) {
        return $self->property;
    }
    else {
        return $self->end_property
            if $context->in_property_context;

        $self->{next_state} = $context->leave_object_context->[0];
        return token( END_OBJECT );
    }
}

sub property {
    my ($self) = @_;

    $self->log( 'Entering `property`' ) if DEBUG;

    my $context = $self->{context};
    my (undef, $data, $state) = @{ $context->current_context_value };

    if ( not $context->in_property_context ) {
        my $key = shift @$state;

        # if we have no keys, just
        # return back to object ...
        return $self->object if not defined $key;

        $context->enter_property_context( [ \&end_property, $data->{ $key }, [] ] );
        $self->{next_state} = \&property;
        return token( START_PROPERTY, $key );
    }
    else {
        my $value = $self->_dispatch_on_type( $data );

        return $value if is_error( $value );

        $self->{next_state} ||= \&end_property;

        return $value;
    }
}

sub end_property {
    my ($self) = @_;

    $self->log( 'Entering `end_property`' ) if DEBUG;

    $self->{context}->leave_property_context;
    $self->{next_state} = \&object;
    return token( END_PROPERTY );
}

sub array {
    my ($self) = @_;

    $self->log( 'Entering `array`' ) if DEBUG;

    my $context = $self->{context};
    my (undef, $data, $state) = @{ $context->current_context_value };

    if ( scalar @$state ) {
        my $i = shift @$state;
        $self->{next_state} = \&array;
        return $self->_dispatch_on_type( $data->[ $i ] );
    }
    else {
        $self->{next_state} = $context->leave_array_context->[0];
        return token( END_ARRAY );
    }
}

sub _dispatch_on_type {
    my ($self, $data) = @_;

    $self->log( 'Entering `_dispatch_on_type`' ) if DEBUG;

    if ( ref $data eq 'HASH' ) {
        $self->{context}->enter_object_context( [ \&object, $data, [ sort keys %$data ] ] );
        $self->{next_state} = \&property;
        return token( START_OBJECT );
    }
    elsif ( ref $data eq 'ARRAY' ) {
        $self->{context}->enter_array_context( [ \&array, $data, [ 0 .. $#{$data} ] ] );
        $self->{next_state} = \&array;
        return token( START_ARRAY );
    }

    return token( ADD_NULL ) if not defined $data;

    if ( ref $data eq 'SCALAR' ) {
        if ( $$data ) {
            return token( ADD_TRUE );
        }
        else {
            return token( ADD_FALSE );
        }
    }

    if ( Scalar::Util::looks_like_number( $data ) ) {
        if ( $data =~ /\./ ) {
            return token( ADD_FLOAT, $data );
        }
        else {
            return token( ADD_INT, $data );
        }
    }

    return token( ADD_STRING, $data );
}

# logging

sub log {
    my ($self, @msg) = @_;
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# ...

1;

__END__

=pod

=cut
