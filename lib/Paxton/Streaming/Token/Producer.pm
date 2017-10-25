package Paxton::Streaming::Token::Producer;
# ABSTRACT: Stream an array of tokens, maintining context
use Moxie;

use Paxton::Util::Tokens;

use Paxton::Core::Context;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_TOKEN_ITERATOR_DEBUG} // 0;

# ...

extends 'Moxie::Object';
   with 'Paxton::Streaming::API::Producer';

## slots

has _source  => sub { die 'You must specify an array of `source` to iterate over.'};
has _context => sub { Paxton::Core::Context->new };
has _index   => sub { 0 };
has _done    => sub { 0 };

my sub _source  : private;
my sub _context : private;
my sub _index   : private;
my sub _done    : private;

## constructor

sub BUILDARGS : init_args(
    source   => '_source',
    context? => '_context',
);

sub BUILD ($self, $) {
    # initialize the state ...
    _context->enter_root_context;
}

# accessor

sub context : ro('_context');

# ...

sub is_exhausted : ro('_done');

sub produce_token ($self) {
    return if _done;

    my $idx = _index;
    _index++;

    if ( _index >= scalar _source->@* ) {
        _done = 1;
    }

    my $token      = _source->[ $idx ];
    my $token_type = $token->type;

    if ( $token_type == START_OBJECT ) {
        _context->enter_object_context;
    }
    elsif ( $token_type == END_OBJECT ) {
        _context->leave_object_context;
    }
    elsif ( $token_type == START_PROPERTY ) {
        _context->enter_property_context;
    }
    elsif ( $token_type == END_PROPERTY ) {
        _context->leave_property_context;
    }
    elsif ( $token_type == START_ARRAY ) {
        _context->enter_array_context;
    }
    elsif ( $token_type == END_ARRAY ) {
        _context->leave_array_context;
    }
    elsif ( $token_type == START_ITEM ) {
        _context->enter_item_context;
    }
    elsif ( $token_type == END_ITEM ) {
        _context->leave_item_context;
    }

    return $token;
}

# logging

sub log ($self, @msg) {
    (DEBUG > 1) ? Carp::cluck( @msg ) : warn( @msg, "\n" );
    return;
}

1;

__END__

=pod

=cut
