package Paxton::Streaming::Encoder;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use UNIVERSAL::Object;
use MOP::Method;

use Paxton::Core::API::Reader;

use Paxton::Core::Exception;
use Paxton::Core::Tokens;
use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_ENCODER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::Core::API::Reader') }
our %HAS;  BEGIN {
    %HAS = (
        source  => sub { die 'You must specify a `source` to encode.'},
        context => sub { Paxton::Core::Context->new },
        # private ...
        _done   => sub { 0 },
    )
}

sub BUILD {
    my ($self) = @_;
    # initialize the state ...
    $self->{context}->enter_root_context(
        [ \&start, $self->{source} ]
    );
}

# ...

sub is_done {
    my ($self) = @_;
    return $self->{_done};
}

sub get_token {
    my ($self) = @_;

    return if $self->{_done};

    my ($next, $data, $state) = @{ $self->{context}->current_context_value };

    require Data::Dumper if DEBUG;
    $self->log( '>> CURRENT => ', MOP::Method->new( $next )->name                 ) if DEBUG;
    $self->log( '   CONTEXT => ', join ', ' => map $_->[0], @{ $self->{context} } ) if DEBUG;
    $self->log( '   DATA    => ', Data::Dumper::Dumper( $data )  =~ s/\n$//r      ) if DEBUG;
    $self->log( '   STATE   => ', Data::Dumper::Dumper( $state ) =~ s/\n$//r      ) if DEBUG;

    my $token = $self->$next();

    (defined $token && is_token( $token ))
        || Paxton::Core::Exception->new( message => 'Invalid token ('.$token.')' )->throw;

    return if $token->type == NO_TOKEN;

    if ( is_error( $token ) ) {
        $self->log( 'Encountered error: ', $token->value ) if DEBUG;
    }

    # if we are back into root context
    # that pretty much means we are done
    # so we can do this ...
    if ( $self->{context}->in_root_context ) {
        $self->{_done} = 1;
    }

    return $token;
}

# ...

sub start {
    my ($self) = @_;

    my $context = $self->{context};
    my $depth   = $context->depth;
    my (undef, $data, undef) = @{ $context->current_context_value };

    if ( ref $data eq 'HASH' ) {
        return $self->object;
    }
    elsif ( ref $data eq 'ARRAY' ) {
        return $self->array;
    }
    else {
        return $self->literal( $data );
    }
}

sub object {
    my ($self) = @_;

    my $context = $self->{context};
    my $depth   = $context->depth;
    my (undef, $data, $state) = @{ $context->current_context_value };

    if ( not $context->in_object_context ) {
        $context->enter_object_context( [ \&object, $data, [ sort keys %$data ] ] );
        return token( START_OBJECT );
    }
    else {
        if ( scalar @$state ) {
            return $self->property;
        }
        else {
            $context->leave_object_context;
            return token( END_OBJECT );
        }
    }
}

sub property {
    my ($self) = @_;

    my $context = $self->{context};
    my $depth   = $context->depth;
    my (undef, $data, $state) = @{ $context->current_context_value };

    if ( not $context->in_property_context ) {
        my $key = shift @$state;
        $context->enter_property_context( [ \&property, $data->{ $key } ] );
        return token( START_PROPERTY, $key );
    }
    else {
        my $value = $self->start;

        return $value if is_error( $value );

        # if we have not moved
        # into a new context, then
        # we can end the property
        $context->current_context_value->[0] = \&end_property
            if $context->depth == $depth;

        return $value;
    }
}

sub end_property {
    my ($self) = @_;

    my $context = $self->{context};
    my $depth   = $context->depth;
    my (undef, undef, undef) = @{ $context->current_context_value };

    $context->leave_property_context;
    return token( END_PROPERTY );
}

sub array {
    my ($self) = @_;

    my $context = $self->{context};
    my $depth   = $context->depth;
    my (undef, $data, $state) = @{ $context->current_context_value };

    if ( not $context->in_array_context ) {
        $context->enter_array_context( [ \&array, $data, [ 0 .. $#{$data} ] ] );
        return token( START_ARRAY );
    }
    else {
        my (undef, $array, $indices) = @{ $context->current_context_value };

        if ( scalar @$indices ) {
            my $idx = shift @$indices;
            return $self->literal( $array->[ $idx ] );
        }
        else {
            $context->leave_array_context;
            return token( END_ARRAY );
        }
    }
}

sub literal {
    my ($self, $data) = @_;

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
