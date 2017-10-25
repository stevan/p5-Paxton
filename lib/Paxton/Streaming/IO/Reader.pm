package Paxton::Streaming::IO::Reader;
# ABSTRACT: Convert a JSON string into a stream of tokens
use Moxie;

use Carp         ();
use Scalar::Util ();
use MOP::Method;

use IO::Handle;
use IO::Scalar;

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

use Paxton::Core::CharBuffer;
use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_READER_DEBUG} // 0;

# ...

extends 'Moxie::Object';
   with 'Paxton::Streaming::API::Producer';

## slots

has _source     => sub { die 'You must specify a `source` to read from.'};
has _next_state => sub { \&root };
has _context    => sub { Paxton::Core::Context->new };

my sub _source     : private;
my sub _next_state : private;
my sub _context    : private;

sub BUILDARGS : init_args(
    source      => '_source',
    next_state? => '_next_state',
    context?    => '_context',
);

## Constructors

sub new_from_path ($class, $path) {
    (defined $path && -f $path)
        || throw('The path must be specified and be valid' );

    my $handle = IO::File->new( $path, 'r' )
        or throw('Unable to open file('.$path.') for reading because: '.$!);

    $class->new( source => Paxton::Core::CharBuffer->new( handle => $handle ) );
}

sub new_from_handle ($class, $handle) {
    (Scalar::Util::blessed( $handle ) && $handle->isa('IO::Handle'))
        || throw('The handle must be derived from IO::Handle' );

    $class->new( source => Paxton::Core::CharBuffer->new( handle => $handle ) );
}

sub new_from_string ($class, $string_ref) {
    (defined $string_ref && ref $string_ref eq 'SCALAR')
        || throw('The string must be a SCALAR reference' );

    return $class->new_from_handle( IO::Scalar->new( $string_ref ) );
}

# ...

sub BUILD ($self, $) {
    (Scalar::Util::blessed( _source ) && _source->isa('Paxton::Core::CharBuffer') )
        || throw('The `source` must be an instance of `Paxton::Core::CharBuffer`' );

    # TODO:
    # check to make sure the handle
    # is actually readable.
    # - SL

    # enter the root context now ...
    _context->enter_root_context( \&start );
}

# accessors (nothing really needs to be secret)

sub source     : ro('_source');
sub next_state : ro('_next_state');
sub context    : ro('_context');

# iteration API

sub is_exhausted ($self) {
    _source->is_done
        &&
    _context->in_root_context;
}

# NOTE:
# these won't work with the lvalues
# because they need to act on the
# hash key, not a lvalue
sub _has_no_available_next_state { ! exists $_[0]->{_next_state} }
sub _advance_to_next_state       {   delete $_[0]->{_next_state} }

sub produce_token ($self) {
    return if $self->is_exhausted;

    if ( my $next = $self->_advance_to_next_state ) {

        $self->log( '>> CURRENT => ', MOP::Method->new( $next )->name ) if DEBUG;
        $self->log( '   CONTEXT => ', join ', ' => map $_->{type}, @{ +_context } ) if DEBUG;
        $self->log( '   BUFFER  => \'', _source->{buffer}, '\'' ) if DEBUG;

        my $token = $self->$next();

        (defined $token && is_token( $token ))
            || throw('Invalid token ('.$token.')' );

        return if $token->type == NO_TOKEN;

        if ( is_error( $token ) ) {
            $self->log( 'Encountered error: ', $token->value ) if DEBUG;
        }
        elsif ( $self->_has_no_available_next_state ) {
            Paxton::Core::Exception
                ->new( message => 'Next state is not specified after '.$token->to_string )
                ->throw;
        }

        $self->log( '<< NEXT <= ', _next_state ? MOP::Method->new( _next_state )->name : 'NONE' ) if DEBUG;

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

# logging

sub log ($self, @msg) {
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

# delegated charbuffer methods

sub get_next_char               : handles('_source->get');
sub peek_next_char              : handles('_source->peek');
sub skip_next_char              : handles('_source->skip');
sub discard_whitespace_and_peek : handles('_source->discard_whitespace_and_peek');

# parse methods

sub root ($self) {
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

sub end ($self) {
    $self->log( 'Entering `end`' ) if DEBUG;
    # NOTE:
    # this token type works for
    # now, but we might want to
    # be more specific later.
    # - SL
    return token( NO_TOKEN );
}

sub start ($self) {
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

sub object ($self) {
    $self->log( 'Entering `object`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '{' ) {
            $self->skip_next_char;
            _context->enter_object_context( \&object );
            _next_state = \&property;
            return token( START_OBJECT );
        }
        elsif ( $char eq '}' ) {
            # close any open properties ...
            return $self->end_property
                if _context->in_property_context;

            # now close any objects ...
            $self->skip_next_char;
            _next_state = _context->leave_object_context;
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

sub property ($self) {
    $self->log( 'Entering `property`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '"' ) {
            my $key = $self->string_literal;

            return $key if is_error( $key );

            _context->enter_property_context( \&end_property );
            _next_state = \&property;
            return token( START_PROPERTY, $key->value );
        }
        elsif ( $char eq ':' ) {
            $self->skip_next_char;
            my $value = $self->start;

            return $value if is_error( $value );

            # if no next-state has been
            # queued up, we can end the
            # property
            _next_state ||= \&end_property;

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

sub end_property ($self) {
    $self->log( 'Entering `end_property`' ) if DEBUG;

    _context->leave_property_context;
    _next_state = \&object;
    return token( END_PROPERTY );
}

sub array ($self) {
    $self->log( 'Entering `array`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq '[' ) {
            $self->skip_next_char;
            _context->enter_array_context( \&array );
            _next_state = \&item;
            return token( START_ARRAY );
        }
        elsif ( $char eq ']' ) {
            # close any open properties ...
            return $self->end_item
                if _context->in_item_context;

            # now close any objects ...
            $self->skip_next_char;
            _next_state = _context->leave_array_context;
            return token( END_ARRAY );
        }
        elsif ( $char eq ',' ) {
            $self->skip_next_char;
            return $self->item;
        }
        else {
            return token( ERROR, 'Expected end of array or start of item name but found ('.$char.')' );
        }
    }
    else {
        return $self->end;
    }
}

sub item ($self) {
    $self->log( 'Entering `item`' ) if DEBUG;

    my $char = $self->discard_whitespace_and_peek;

    if ( defined $char ) {
        if ( $char eq ']' ) {
            return $self->array;
        }
        elsif ( not _context->in_item_context ) {
            my $idx = _context->get_current_item_count;
            _context->enter_item_context( \&end_item );
            _next_state = \&item;
            return token( START_ITEM, $idx );
        }
        else {
            my $value = $self->start;

            return $value if is_error( $value );

            # if no next-state has been
            # queued up, we can end the
            # item
            _next_state ||= \&end_item;

            return $value;
        }
    }
    else {
        return $self->end;
    }
}

sub end_item ($self) {
    $self->log( 'Entering `end_item`' ) if DEBUG;

    _context->leave_item_context;
    _next_state = \&array;
    return token( END_ITEM );
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

sub string_literal ($self) {
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

sub numeric_literal ($self) {
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
                Carp::confess('Unimplemented (scientific notation)');

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

sub true_literal ($self) {
    $self->_match_literal(
        ['t', 'r', 'u', 'e'],
        ADD_TRUE,
        'Expected end of `true` literal, not(%s)'
    );
}

sub false_literal ($self) {
    $self->_match_literal(
        ['f', 'a', 'l', 's', 'e'],
        ADD_FALSE,
        'Expected end of `false` literal, not(%s)'
    );
}

sub null_literal ($self) {
    $self->_match_literal(
        ['n', 'u', 'l', 'l'],
        ADD_NULL,
        'Expected end of `null` literal, not(%s)'
    );
}

## ....

sub _match_literal ($self, $expected, $token_type, $error_message) {
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
