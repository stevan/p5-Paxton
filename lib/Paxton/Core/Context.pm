package Paxton::Core::Context;
# ABSTRACT: One stop for all your JSON needs
use Moxie;
use Moxie::Enum;

use Scalar::Util ();

use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# contstants ...

enum ContextType => qw[
    ROOT
    IN_OBJECT
    IN_ARRAY
    IN_PROPERTY
    IN_ITEM
];

## ...

extends 'Moxie::Object';

## slots

has _stack     => sub { +[] };
has _callbacks => sub { +{} };

my sub _stack     : private;
my sub _callbacks : private;

# ...

sub depth ($self) { scalar _stack->@* }

sub current_context_value ($self) { _stack->[-1]->{value} }

## observable methods

sub bind_event ($self, $event_name, $callback) {
    _callbacks->{ $event_name } = []
        unless exists _callbacks->{ $event_name };
    push _callbacks->{ $event_name }->@* => $callback;
    $self;
}

sub unbind_event ($self, $event_name, $callback) {
    return $self unless _callbacks->{ $event_name };
    _callbacks->{ $event_name }->@* = grep {
        Scalar::Util::refaddr($_) != Scalar::Util::refaddr($callback)
    } _callbacks->{ $event_name }->@*;
    $self;
}

sub fire_event ($self, $event_name, @args) {
    if ( exists _callbacks->{ $event_name } ) {
        $self->$_( @args ) foreach _callbacks->{ $event_name }->@*;
    }
    if ( exists _callbacks->{'_'} ) {
        $self->$_( $event_name, @args ) foreach _callbacks->{'_'}->@*;
    }
    return;
}

# predicates

sub in_root_context ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{type} == ROOT;
}

sub in_object_context ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{type} == IN_OBJECT;
}

sub in_array_context ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{type} == IN_ARRAY;
}

sub in_property_context ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{type} == IN_PROPERTY;
}

sub in_item_context ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{type} == IN_ITEM;
}

# data ...

sub get_current_item_count ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{item_count};
}

sub get_current_property_count ($self) {
    return unless scalar _stack->@* && defined _stack->[-1];
    return _stack->[-1]->{property_count};
}

# enter ...

sub enter_root_context ($self, $value = undef) {
    (scalar _stack->@* == 0)
        || throw('Unable to enter root context: stack not empty');

    push _stack->@* => { type => ROOT, value => $value };
    return;
}

sub enter_object_context ($self, $value = undef) {
    (scalar _stack->@*)
        || throw('Unable to enter object context: stack is empty');

    push _stack->@* => { type => IN_OBJECT, value => $value, property_count => 0 };
    $self->fire_event( enter_object_context => $value );
    return;
}

sub enter_array_context ($self, $value = undef) {
    (scalar _stack->@*)
        || throw('Unable to enter array context: stack is empty');

    (not $self->in_object_context)
        || throw('Unable to enter array context from within object context (must be in property context)');

    push _stack->@* => { type => IN_ARRAY, value => $value, item_count => 0 };
    $self->fire_event( enter_array_context => $value );
    return;
}

sub enter_property_context ($self, $value = undef) {
    (scalar _stack->@*)
        || throw('Unable to enter property context: stack is empty');

    ($self->in_object_context)
        || throw('Unable to enter property context from within anything but object context');

    # increment the property counter
    _stack->[-1]->{property_count}++;

    push _stack->@* => { type => IN_PROPERTY, value => $value };
    $self->fire_event( enter_property_context => $value );
    return;
}

sub enter_item_context ($self, $value = undef) {
    (scalar _stack->@*)
        || throw('Unable to enter item context: stack is empty');

    ($self->in_array_context)
        || throw('Unable to enter item context from within anything but array context');

    # increment the property counter
    _stack->[-1]->{item_count}++;

    push _stack->@* => { type => IN_ITEM, value => $value };
    $self->fire_event( enter_item_context => $value );
    return;
}

# leave

sub leave_object_context ($self) {
    (scalar _stack->@*)
        || throw('Unable to leave context: stack exhausted');

    (_stack->[-1]->{type} == IN_OBJECT)
        || throw('Must be in `object` context, not '._stack->[-1]->{type} );

    pop _stack->@*;
    $self->fire_event( 'leave_object_context' );

    # return nothing if we got nothing ...
    return unless scalar _stack->@*;
    # otherwise restore the previous context ...
    return _stack->[-1]->{value};
}

sub leave_array_context ($self) {
    (scalar _stack->@*)
        || throw('Unable to leave context: stack exhausted');

    (_stack->[-1]->{type} == IN_ARRAY)
        || throw('Must be in `array` context, not '._stack->[-1]->{type} );

    pop _stack->@*;
    $self->fire_event( 'leave_array_context' );

    # return nothing if we got nothing ...
    return unless scalar _stack->@*;
    # otherwise restore the previous context ...
    return _stack->[-1]->{value};
}

sub leave_property_context ($self) {
    (scalar _stack->@*)
        || throw('Unable to leave context: stack exhausted');

    (_stack->[-1]->{type} == IN_PROPERTY)
        || throw('Must be in `property` context, not '._stack->[-1]->{type} );

    pop _stack->@*;
    $self->fire_event( 'leave_property_context' );

    # return nothing if we got nothing ...
    return unless scalar _stack->@*;
    # otherwise restore the previous context ...
    return _stack->[-1]->{value};
}

sub leave_item_context ($self) {
    (scalar _stack->@*)
        || throw('Unable to leave context: stack exhausted');

    (_stack->[-1]->{type} == IN_ITEM)
        || throw('Must be in `item` context, not '._stack->[-1]->{type} );

    pop _stack->@*;
    $self->fire_event( 'leave_item_context' );

    # return nothing if we got nothing ...
    return unless scalar _stack->@*;
    # otherwise restore the previous context ...
    return _stack->[-1]->{value};
}

sub leave_current_context ($self) {
    (scalar _stack->@*)
        || throw('Unable to leave context: stack exhausted');

    my $event_name = $self->in_object_context
        ? 'leave_object_context'
        : $self->in_array_context
            ? 'leave_array_context'
            : $self->in_property_context
                ? 'leave_property_context'
                : $self->in_item_context
                    ? 'leave_item_context'
                    : undef;

    pop _stack->@*;
    $self->fire_event( $event_name ) if $event_name;

    # return nothing if we got nothing ...
    return unless scalar _stack->@*;
    # otherwise restore the previous context ...
    return _stack->[-1]->{value};
}

1;

__END__

=pod

=cut
