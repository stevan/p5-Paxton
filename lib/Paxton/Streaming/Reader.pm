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

# context ...

use constant IN_OBJECT   => Scalar::Util::dualvar( 1, 'IN_OBJECT'   );
use constant IN_ARRAY    => Scalar::Util::dualvar( 2, 'IN_ARRAY'    );
use constant IN_PROPERTY => Scalar::Util::dualvar( 3, 'IN_PROPERTY' );

# ...

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        source     => sub { die 'You must specify a `source` to use.'},
        next_state => sub { \&root },
        context    => sub { +[] },
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

    if ( my $next = delete $self->{next_state} ) {

        $self->log( '>> CURRENT => ', MOP::Method->new( $next )->name   ) if DEBUG;
        $self->log( '   CONTEXT => ', join ', ' => @{$self->{context}}  ) if DEBUG;
        $self->log( '   BUFFER  => \'', $self->{source}->{buffer}, '\'' ) if DEBUG;

        my $token = $self->$next();

        (defined $token && is_token( $token ))
            || Paxton::Core::Exception->new( message => 'Invalid token ('.$token.')' )->throw;

        return if $token->type == NO_TOKEN;

        if ( is_error( $token ) ) {
            $self->log( 'Encountered error: ', $token->payload ) if DEBUG;
        }
        elsif ( not exists $self->{next_state} ) {
            Paxton::Core::Exception
                ->new( message => 'Next state is not specified after '.$token->as_string )
                ->throw;
        }

        $self->log( '<< NEXT <= ', $self->{next_state} ? MOP::Method->new( $self->{next_state} )->name : 'NONE' ) if DEBUG;

        return $token;
    }
    else {
        # TODO:
        # We are going to need to handle the
        # case where there is no `next_state` and
        # we still have source to process.
        # - SL
    }

    return;
}

sub skip_token;

# logging

sub log {
    my ($self, @msg) = @_;
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# delegated charbuffer methods

sub get_next_char  { $_[0]->{source}->get  }
sub peek_next_char { $_[0]->{source}->peek }
sub skip_next_char { $_[0]->{source}->skip }
sub discard_whitespace_and_peek {
    $_[0]->{source}->discard_whitespace_and_peek
}

# parse methods

sub root {
    my ($self) = @_;

    $self->log( 'Entering `root`' ) if DEBUG;

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

    $self->log( 'Entering `end`' ) if DEBUG;
    # NOTE:
    # this token type works for
    # now, but we might want to
    # be more specific later.
    # - SL
    return token( NO_TOKEN );
}

sub start {
    my ($self) = @_;

    $self->log( 'Entering `start`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '{' ) {
            return $self->object;
        }
        elsif ( $char eq '[' ) {
            return $self->array;
        }
        elsif ( $char eq '"' ) {
            return $self->string_literal;
        }
        elsif ( $char eq '-' ||  $char =~ /^[0-9]$/ ) {
            return $self->numeric_literal;
        }
        elsif ( $char eq 't' ) {
            return $self->true_literal;
        }
        elsif ( $char eq 'f' ) {
            return $self->false_literal;
        }
        elsif ( $char eq 'n' ) {
            return $self->null_literal;
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

    $self->log( 'Entering `object`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '{' ) {
            $self->skip_next_char;
            push @{ $self->{context} } => IN_OBJECT;
            $self->{next_state} = \&property;
            return token( START_OBJECT );
        }
        elsif ( $char eq '}' ) {
            # close any open properties ...
            if ( $self->{context}->[-1] == IN_PROPERTY ) {
                return $self->end_property;
            }

            # now close any objects ...
            $self->skip_next_char;
            if ( $self->{context}->[-1] == IN_OBJECT ) {

                my $ctx = $self->{context}->[-2];
                if ( not defined $ctx ) {
                    $self->{next_state} = \&start;
                }
                elsif ( $ctx == IN_OBJECT ) {
                    $self->{next_state} = \&object;
                }
                elsif ( $ctx == IN_ARRAY ) {
                    $self->{next_state} = \&array;
                }
                elsif ( $ctx == IN_PROPERTY ) {
                    $self->{next_state} = \&end_property;
                }

                pop @{ $self->{context} };
            }
            else {
                $self->{next_state} = \&start;
            }
            return token( END_OBJECT );
        }
        elsif ( $char eq ',' ) {
            $self->skip_next_char;
            return $self->property;
        }
        else {
            return token( ERROR, 'Expected end of object or start of property name but found ('.$char.')' );
        }
    }
    else {
        return $self->end;
    }
}

sub property {
    my ($self) = @_;

    $self->log( 'Entering `property`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '"' ) {
            my $key = $self->string_literal;

            return $key if is_error( $key );

            push @{ $self->{context} } => IN_PROPERTY;
            $self->{next_state} = \&property;
            return token( START_PROPERTY, $key->payload );
        }
        elsif ( $char eq ':' ) {
            $self->skip_next_char;
            my $value = $self->start;

            return $value if is_error( $value );

            # if no next-state has been
            # queued up, we can end the
            # property
            $self->{next_state} ||= \&end_property;

            return $value;
        }
        else {
            return $self->object;
        }
    }
    else {
        return $self->end;
    }
}

sub end_property {
    my ($self) = @_;

    $self->log( 'Entering `end_property`' ) if DEBUG;

    if ( $self->{context}->[-1] == IN_PROPERTY ) {
        pop @{ $self->{context} };
    }

    $self->{next_state} = \&object;
    return token( END_PROPERTY );
}

sub array {
    my ($self) = @_;

    $self->log( 'Entering `array`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '[' ) {
            $self->skip_next_char;
            push @{ $self->{context} } => IN_ARRAY;
            $self->{next_state} = \&array;
            return token( START_ARRAY );
        }
        elsif ( $char eq ']' ) {
            $self->skip_next_char;
            if ( $self->{context}->[-1] == IN_ARRAY ) {

                my $ctx = $self->{context}->[-2];
                if ( not defined $ctx ) {
                    $self->{next_state} = \&start;
                }
                elsif ( $ctx == IN_OBJECT ) {
                    $self->{next_state} = \&object;
                }
                elsif ( $ctx == IN_ARRAY ) {
                    $self->{next_state} = \&array;
                }
                elsif ( $ctx == IN_PROPERTY ) {
                    $self->{next_state} = \&end_property;
                }

                pop @{ $self->{context} };
            }
            else {
                $self->{next_state} = \&start;
            }
            return token( END_ARRAY );
        }
        elsif ( $char eq ',' ) {
            $self->skip_next_char;
        }

        $self->{next_state} = \&array;
        return $self->start;
    }
    else {
        return $self->end;
    }
}

## ....

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

sub string_literal {
    my ($self) = @_;

    $self->log( 'Entering `string_literal`' ) if DEBUG;

    my $char = $self->get_next_char;

    return token( ERROR, 'String must begin with a double-quote character' )
        unless $char eq '"';

    if ( defined $char ) {

        my $acc = '';
        while (1) {
            $char = $self->get_next_char;
            return token( ERROR, 'Unterminated string' ) unless defined $char;

            last if $char eq '"';

            if ($char eq "\\") {
                my $escape_char = $self->get_next_char;
                return token( ERROR, 'Unfinished escape sequence' )
                    unless defined $escape_char;
                return token( ERROR, '\u sequence not yet supported' )
                    if $escape_char eq 'u';
                return token( ERROR, 'Invalid escape sequence $escape_char' )
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

sub numeric_literal {
    my ($self) = @_;

    $self->log( 'Entering `numeric_literal`' ) if DEBUG;

    my $char = $self->peek_next_char;

    if ( defined $char ) {

        my $ttype  = ADD_INT;
        my $number = '';

        if ( $char eq '-' ) {
            $number .= $char;
            $self->skip_next_char;
        }

        while (1) {
            $char = $self->peek_next_char;

            return token( ERROR, 'Unexpected end of input' )
                if not defined $char;

            if ( $char =~ /^\d$/ ) {
                $number .= $char;
                $self->skip_next_char;
            }
            elsif ( $char eq '.' ) {
                # if the previous character is not
                # a digit, then we need to error here
                return token( ERROR, 'Invalid number ('.$number.') cannot be followed by `.`' )
                    if $number eq '' || $number eq '-';

                $ttype   = ADD_FLOAT;
                $number .= $char;
                $self->skip_next_char;
            }
            elsif ( $char eq 'e' ) {
                # $char = _peek_char( $_[0] );
                # if ( defined $char && $char =~ /e/i ) {
                #     push @acc, $char;
                #     chop $_[0]->{buffer};
                #     $char = _peek_char( $_[0] );
                #     if ( defined $char && ($char eq '+' || $char eq '-') ) {
                #         push @acc, $char;
                #         chop $_[0]->{buffer};
                #     }
                #     $digit = _accum_digits( $_[0] );
                #     return [ ERROR, 'Expected digits but got '.($_[0]->{buffer} || 'EOF') ]
                #         if $digit eq '';
                #     push @acc, $digit;
                # }
            }
            else {
                last;
            }
        }

        return token( ERROR, 'Invalid number ('.$number.') has no digits in it' )
            if $number !~ /\d/;

        return token( $ttype, $number );
    }
    else {
        return $self->end;
    }
}

sub true_literal {
    $_[0]->_match_literal(
        ['t', 'r', 'u', 'e'],
        ADD_TRUE,
        'Expected end of `true` literal, not(%s)'
    );
}

sub false_literal {
    $_[0]->_match_literal(
        ['f', 'a', 'l', 's', 'e'],
        ADD_FALSE,
        'Expected end of `false` literal, not(%s)'
    );
}

sub null_literal {
    $_[0]->_match_literal(
        ['n', 'u', 'l', 'l'],
        ADD_NULL,
        'Expected end of `null` literal, not(%s)'
    );
}

## ....

sub _match_literal {
    my ($self, $expected, $token_type, $error_message) = @_;

    $self->log( 'Entering `' . (join '' => @$expected) . '`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {

        my $received = '';
        my @expected = @$expected;
        while ( @expected ) {
            if ( $char eq shift @expected ) {
                $received .= $char;
                $self->skip_next_char;
                $char = $self->peek_next_char;
            }
            else {
                last;
            }
        }

        if ( @expected ) {
            return token( ERROR, sprintf( $error_message, $received ) );
        }
        else {
            return token( $token_type );
        }
    }
    else {
        return $self->end;
    }
}

1;

__END__

=pod

=cut
