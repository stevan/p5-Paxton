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

    (defined $token && is_token($token))
        || Paxton::Core::Exception->new( message => 'Invalid token: '.$token )->throw;

    my $sink       = $self->{sink};
    my $token_type = $token->type;

    if ( $token_type == START_OBJECT ) {
        $sink->print('{');
    }
    elsif ( $token_type == END_OBJECT ) {
        $sink->print('}');
    }
    elsif ( $token_type == START_PROPERTY ) {
        $sink->printf('"%s":' => $token->value);
    }
    elsif ( $token_type == END_PROPERTY ) {
        ;
    }
    elsif ( $token_type == START_ARRAY ) {
        $sink->print('[');
    }
    elsif ( $token_type == END_ARRAY ) {
        $sink->print(']');
    }
    elsif ( is_numeric( $token ) ) {
        $sink->print($token->value);
    }
    elsif ( $token_type == ADD_STRING ) {
        $sink->printf('"%s"' => $token->value);
    }
    elsif ( $token_type == ADD_TRUE ) {
        $sink->print('true');
    }
    elsif ( $token_type == ADD_FALSE ) {
        $sink->print('false');
    }
    elsif ( $token_type == ADD_NULL ) {
        $sink->print('null');
    }
    else {
        Paxton::Core::Exception->new( message => 'Unkown token type: '.$token_type )->throw;
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
