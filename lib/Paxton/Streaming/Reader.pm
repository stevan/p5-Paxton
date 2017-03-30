package Paxton::Streaming::Reader;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Carp         ();
use Scalar::Util ();
use UNIVERSAL::Object;

use IO::Handle;
use IO::Scalar;

use Paxton::Core::Tokens;
use Paxton::Core::CharBuffer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        source  => sub { die 'You must specify a `source` to use.'},
        stack   => sub { +[ \&root ] },
    )
}

## Constructors

sub new_from_stream {
    my ($class, $stream) = @_;

    (Scalar::Util::blessed( $stream ) && $stream->isa('IO::Handle') )
        || Carp::confess('The stream must be derived from IO::Handle');

    $class->new( source => Paxton::Core::CharBuffer->new( handle => $stream ) );
}

sub new_from_string {
    my ($class, $value) = @_;
    return $class->new_from_stream( IO::Scalar->new(ref $value ? $value : \$value) );
}

# ...

sub BUILD {
    my ($self) = @_;
    (Scalar::Util::blessed( $self->{source} ) && $self->{source}->isa('Paxton::Core::CharBuffer') )
        || Carp::confess('The `source` must be an instance of `Paxton::Core::CharBuffer`');
}

# iteration API

sub is_done {
    my ($self) = @_;
    $self->{source}->is_done;
}

sub next_token {
    my ($self) = @_;

    if ( my $next = $self->pop_stack ) {
        my ($token, $cont) = $self->$next();

        return if $token->type == NO_TOKEN;

        if ( $cont ) {
            $self->push_stack( $cont );
        }
        elsif ( not is_error( $token ) ) {
            $self->push_stack( \&start );
        }

        return $token;
    }

    return;
}

sub skip_token;

# stack methods

sub pop_stack  { pop    @{ $_[0]->{stack} }          }
sub push_stack { push   @{ $_[0]->{stack} } => $_[1] }
sub stack_size { scalar @{ $_[0]->{stack} }          }

# delegated charbuffer methods

sub get  { $_[0]->{source}->get           }
sub peek { $_[0]->{source}->peek          }
sub skip { $_[0]->{source}->skip( $_[1] ) }

# parse methods

sub root {
    my ($self) = @_;

    my $char = $self->peek;

    if ( defined $char ) {

        # NOTE:
        # by default we do not allow
        # there to be a non-ref start
        # node, a restriction we might
        # lift eventually.
        # - SL

        if ( $char eq '{' || $char eq '[' ) {
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

sub end {
    my ($self) = @_;
    if ( $self->stack_size != 0 ) {
        return token( ERROR, 'Unexpected end of input (still have '.$self->stack_size.' items on the stack)' );
    }
    else {
        # NOTE:
        # this token type works for
        # now, but we might want to
        # be more specific later.
        # - SL
        return token( NO_TOKEN );
    }
}

sub start {
    my ($self) = @_;

    my $char = $self->peek;

    if ( defined $char ) {
        if ( $char eq '{' ) {
            $self->skip;
            return token( START_OBJECT ), \&object;
        }
        elsif ( $char eq '[' ) {
            $self->skip;
            return token( START_ARRAY ), \&array;
        }
        elsif ( $char eq '"' ) {
            return $self->string;
        }
        elsif ( $char eq '-' ||  $char =~ /^[0-9]$/ ) {
            return $self->number;
        }
        elsif ( $char eq 't' ) {
            return $self->true_literal;
        }
        elsif ( $char eq 'f' ) {
            return $self->false_literal;
        }
        elsif ( $char eq 'n' ) {
            return $self->nil_literal;
        }
        else {
            return token( ERROR, 'Unrecognized start character ['.$char.']' );
        }
    }
    else {
        return $self->end;
    }
}

sub object {
    my ($self) = @_;

    my $char = $self->peek;

    if ( defined $char ) {
        if ( $char eq '}' ) {
            $self->skip;
            $self->pop_stack;
            return token( END_OBJECT );
        }
        elsif ( $char eq '"' ) {
            return token( START_PROPERTY ), \&property;
        }
        else {
            return token( ERROR, 'Expected end of object or start of property name' );
        }
    }
    else {
        return $self->end;
    }
}

sub property {
    my ($self) = @_;

    my $char = $self->peek;

    if ( defined $char ) {
        if ( $char eq '"' ) {
            return $self->string;
        }
        else {
            return token( ERROR, 'Expected end of array' );
        }
    }
    else {
        return $self->end;
    }
}

sub array {
    my ($self) = @_;

    my $char = $self->peek;

    if ( defined $char ) {
        if ( $char eq ']' ) {
            $self->skip;
            $self->pop_stack;
            return token( END_ARRAY );
        }
        else {
            return token( ERROR, 'Expected end of array' );
        }
    }
    else {
        return $self->end;
    }
}

sub string {
    my ($self) = @_;
    return token( ERROR, 'Unimplemented (string)' );
}

sub number {
    my ($self) = @_;
    return token( ERROR, 'Unimplemented (number)' );
}

sub true_literal {
    my ($self) = @_;
    return token( ERROR, 'Unimplemented (true)' );
}

sub false_literal {
    my ($self) = @_;
    return token( ERROR, 'Unimplemented (false)' );
}

sub nil_literal {
    my ($self) = @_;
    return token( ERROR, 'Unimplemented (nil)' );
}

1;

__END__

=pod

=cut
