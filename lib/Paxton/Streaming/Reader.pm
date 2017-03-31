package Paxton::Streaming::Reader;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();
use UNIVERSAL::Object;
use MOP::Method;

use IO::Handle;
use IO::Scalar;

use Paxton::Core::Exception;
use Paxton::Core::Tokens;
use Paxton::Core::CharBuffer;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_READER_DEBUG} // 0;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        source => sub { die 'You must specify a `source` to use.'},
        cont   => sub { \&root },
    )
}

## Constructors

sub new_from_stream {
    my ($class, $stream) = @_;

    (Scalar::Util::blessed( $stream ) && $stream->isa('IO::Handle') )
        || Paxton::Core::Exception->new( message => 'The stream must be derived from IO::Handle' )->throw;

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
        || Paxton::Core::Exception->new( message => 'The `source` must be an instance of `Paxton::Core::CharBuffer`' )->throw;
}

# iteration API

sub is_done { # this needs a better name
    my ($self) = @_;
    $self->{source}->is_done;
}

sub next_token {
    my ($self) = @_;

    if ( my $next = $self->{cont} ) {

        $self->log( 'Calling => ' . MOP::Method->new( $next )->name ) if DEBUG;

        my ($token, $cont) = $self->$next();

        (defined $token && is_token( $token ))
            || Paxton::Core::Exception->new( message => 'Invalid token ('.$token.')' )->throw;

        return if $token->type == NO_TOKEN;

        if ( $cont ) {
            $self->{cont} = $cont;
        }
        elsif ( not is_error( $token ) ) {
            $self->{cont} = \&start;
        }

        if ( $token->type eq ERROR ) {
            $self->log( 'Encountered error: ', $token->payload ) if DEBUG;
        }

        return $token;
    }

    return;
}

sub skip_token;

# logging

sub log {
    my ($self, @msg) = @_;
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg );
    return;
}

# stack methods

sub stack_size { 1 }

# delegated charbuffer methods

sub get  { $_[0]->{source}->get           }
sub peek { $_[0]->{source}->peek          }
sub skip { $_[0]->{source}->skip( $_[1] ) }

sub discard_whitespace_and_peek {
    $_[0]->{source}->discard_whitespace_and_peek
}

# parse methods

sub root {
    my ($self) = @_;

    my $char = $self->discard_whitespace_and_peek;

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
    # NOTE:
    # this token type works for
    # now, but we might want to
    # be more specific later.
    # - SL
    return token( NO_TOKEN );
}

sub start {
    my ($self) = @_;

    my $char = $self->discard_whitespace_and_peek;

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
            return token( ERROR, 'Unrecognized start character `'.$char.'`' );
        }
    }
    else {
        return $self->end;
    }
}

sub object {
    my ($self) = @_;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '}' ) {
            $self->skip;
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

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '"' ) {
            return $self->string, \&property;
        }
        elsif ( $char eq ':' ) {
            $self->skip;
            my $value = $self->start;

            return $value if is_error( $value );

            $char = $self->discard_whitespace_and_peek;

            if ( $char eq ',' ) {
                $self->skip;
            }
            else {
            }

            return $value, \&end_property;
        }
        else {
            return token( ERROR, 'Expected end of array' );
        }
    }
    else {
        return $self->end;
    }
}

sub end_property {
    my ($self) = @_;
    return token( END_PROPERTY ), \&object;
}

sub array {
    my ($self) = @_;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq ']' ) {
            $self->skip;
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

our %ESCAPE_CHARS = (
    b => "\b",
    f => "\f",
    n => "\n",
    r => "\r",
    t => "\t",
    "\\" => "\\",
    "/" => "/",
    '"' => '"',
);

sub string {
    my ($self) = @_;

    my $char = $self->get;

    if ( defined $char ) {

        my $acc = '';
        while (1) {
            $char = $self->get;
            return token( ERROR, "Unterminated string" ) unless defined $char;

            last if $char eq '"';

            if ($char eq "\\") {
                my $escape_char = $self->get;
                return token( ERROR, "Unfinished escape sequence" )
                    unless defined $escape_char;
                return token( ERROR, "\\u sequence not yet supported" )
                    if $escape_char eq 'u';
                return token( ERROR, "Invalid escape sequence \\$escape_char" )
                    unless exists $ESCAPE_CHARS{ $escape_char };
                $acc .= $ESCAPE_CHARS{ $escape_char };
            }
            else {
                $acc .= $char;
            }
        }

        return token( ADD_STRING, $acc );
    }
    else {
        return $self->end;
    }
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
