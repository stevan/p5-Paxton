package Paxton::Streaming::Writer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Carp         ();
use Scalar::Util ();
use UNIVERSAL::Object;

use IO::Handle;
use IO::Scalar;

use Paxton::Core::API::Writer;

use Paxton::Core::Exception;
use Paxton::Core::Tokens;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_WRITER_DEBUG} // 0;

# ...

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object') }
our @DOES; BEGIN { @DOES = ('Paxton::Core::API::Writer') }
our %HAS;  BEGIN {
    %HAS = (
        sink    => sub { die 'You must specify a `sink` to write to.'},
        #context => sub { +[] },
    )
}

## Constructors

sub new_to_handle {
    my ($class, $handle) = @_;

    (Scalar::Util::blessed( $handle ) && $handle->isa('IO::Handle') )
        || Paxton::Core::Exception->new( message => 'The stream must be derived from IO::Handle' )->throw;

    $class->new( sink => $handle );
}

sub new_to_string {
    my ($class, $string_ref) = @_;

    (defined $string_ref && ref $string_ref eq 'SCALAR')
        || Paxton::Core::Exception->new( message => 'The string must be a SCALAR reference' )->throw;

    return $class->new_to_handle( IO::Scalar->new( $string_ref ) );
}

# ...

sub BUILD {
    my ($self) = @_;
    (Scalar::Util::blessed( $self->{sink} ) && $self->{sink}->isa('IO::Handle') )
        || Paxton::Core::Exception->new( message => 'The `sink` must be an instance of `IO::Handle`' )->throw;

    # TODO:
    # check to make sure the handle
    # is actually writable.
    # - SL
}

# ...

sub put_token {
    my ($self, $token) = @_;
    if ( my $out = $self->_token_to_string( $token ) ) {
        $self->{sink}->print( $out );
    }
}


# ...

sub _token_to_string {
    my ($self, $token) = @_;

    my $token_type = $token->type;

    if ( $token_type == START_OBJECT ) {
        return '{';
    }
    elsif ( $token_type == END_OBJECT ) {
        return '}';
    }
    if ( $token_type == START_PROPERTY ) {
        return sprintf '"%s":' => $token->value;
    }
    if ( $token_type == END_PROPERTY ) {
        return;
    }
    elsif ( $token_type == START_ARRAY ) {
        return '[';
    }
    elsif ( $token_type == END_ARRAY ) {
        return ']';
    }
    elsif ( is_numeric( $token ) ) {
        return ''.$token->value;
    }
    elsif ( $token_type == ADD_STRING ) {
        return sprintf '"%s"' => $token->value;
    }
    elsif ( $token_type == ADD_TRUE ) {
        return 'true'
    }
    elsif ( $token_type == ADD_FALSE ) {
        return 'false'
    }
    elsif ( $token_type == ADD_NULL ) {
        return 'null'
    }
    else {
        die 'Unknown token: ' . $token_type;
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
