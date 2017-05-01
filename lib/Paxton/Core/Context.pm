package Paxton::Core::Context;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Scalar::Util ();

use Paxton::Util::Errors;
use Paxton::Util::Tokens;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# contstants ...

use constant ROOT        => Scalar::Util::dualvar( 1, 'ROOT'        );
use constant IN_OBJECT   => Scalar::Util::dualvar( 2, 'IN_OBJECT'   );
use constant IN_ARRAY    => Scalar::Util::dualvar( 3, 'IN_ARRAY'    );
use constant IN_PROPERTY => Scalar::Util::dualvar( 4, 'IN_PROPERTY' );
use constant IN_ITEM     => Scalar::Util::dualvar( 5, 'IN_ITEM'     );

# constructor ...

sub new ($class) {
    return bless [] => $class;
}

# ...

sub depth ($self) { scalar @$self }

sub current_context_value ($self) { $self->[-1]->{value} }

# predicates

sub in_root_context ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == ROOT;
}

sub in_object_context ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_OBJECT;
}

sub in_array_context ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_ARRAY;
}

sub in_property_context ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_PROPERTY;
}

sub in_item_context ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_ITEM;
}

# data ...

sub get_current_item_count ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{item_count};
}

sub get_current_property_count ($self) {
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{property_count};
}

# enter ...

sub enter_root_context ($self, $value = undef) {
    (scalar @$self == 0)
        || throw('Unable to enter root context: stack not empty');

    push @$self => { type => ROOT, value => $value };
    return;
}

sub enter_object_context ($self, $value = undef) {
    (scalar @$self)
        || throw('Unable to enter object context: stack is empty');

    push @$self => { type => IN_OBJECT, value => $value, property_count => 0 };
    return;
}

sub enter_array_context ($self, $value = undef) {
    (scalar @$self)
        || throw('Unable to enter array context: stack is empty');

    (not $self->in_object_context)
        || throw('Unable to enter array context from within object context (must be in property context)');

    push @$self => { type => IN_ARRAY, value => $value, item_count => 0 };
    return;
}

sub enter_property_context ($self, $value = undef) {
    (scalar @$self)
        || throw('Unable to enter property context: stack is empty');

    ($self->in_object_context)
        || throw('Unable to enter property context from within anything but object context');

    # increment the property counter
    $self->[-1]->{property_count}++;

    push @$self => { type => IN_PROPERTY, value => $value };
    return;
}

sub enter_item_context ($self, $value = undef) {
    (scalar @$self)
        || throw('Unable to enter item context: stack is empty');

    ($self->in_array_context)
        || throw('Unable to enter item context from within anything but array context');

    # increment the property counter
    $self->[-1]->{item_count}++;

    push @$self => { type => IN_ITEM, value => $value };
    return;
}

# leave

sub leave_object_context ($self) {
    (scalar @$self)
        || throw('Unable to leave context: stack exhausted');

    ($self->[-1]->{type} == IN_OBJECT)
        || throw('Must be in `object` context, not '.$self->[-1]->{type} );

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_array_context ($self) {
    (scalar @$self)
        || throw('Unable to leave context: stack exhausted');

    ($self->[-1]->{type} == IN_ARRAY)
        || throw('Must be in `array` context, not '.$self->[-1]->{type} );

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_property_context ($self) {
    (scalar @$self)
        || throw('Unable to leave context: stack exhausted');

    ($self->[-1]->{type} == IN_PROPERTY)
        || throw('Must be in `property` context, not '.$self->[-1]->{type} );

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_item_context ($self) {
    (scalar @$self)
        || throw('Unable to leave context: stack exhausted');

    ($self->[-1]->{type} == IN_ITEM)
        || throw('Must be in `item` context, not '.$self->[-1]->{type} );

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_current_context ($self) {
    (scalar @$self)
        || throw('Unable to leave context: stack exhausted');

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

1;

__END__

=pod

=cut
