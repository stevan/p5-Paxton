package Paxton::Core::Context;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# contstants ...

use constant ROOT        => Scalar::Util::dualvar( 1, 'ROOT'        );
use constant IN_OBJECT   => Scalar::Util::dualvar( 2, 'IN_OBJECT'   );
use constant IN_ARRAY    => Scalar::Util::dualvar( 3, 'IN_ARRAY'    );
use constant IN_PROPERTY => Scalar::Util::dualvar( 4, 'IN_PROPERTY' );
use constant IN_ITEM     => Scalar::Util::dualvar( 5, 'IN_ITEM'     );

# constructor ...

sub new {
    my ($class) = @_;
    return bless [] => $class;
}

# ...

sub depth { scalar @{ $_[0] } }

sub current_context_value { $_[0]->[-1]->{value} }

# predicates

sub in_root_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == ROOT;
}

sub in_object_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_OBJECT;
}

sub in_array_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_ARRAY;
}

sub in_property_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_PROPERTY;
}

sub in_item_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{type} == IN_ITEM;
}

# data ...

sub get_current_item_count {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{item_count};
}

sub get_current_property_count {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->{property_count};
}

# enter ...

sub enter_root_context {
    my ($self, $value) = @_;

    (scalar @$self == 0)
        || Paxton::Core::Exception->new( message => 'Unable to enter root context: stack not empty' )->throw;

    push @$self => { type => ROOT, value => $value };
    return;
}

sub enter_object_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter object context: stack is empty' )->throw;

    push @$self => { type => IN_OBJECT, value => $value, property_count => 0 };
    return;
}

sub enter_array_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter array context: stack is empty' )->throw;

    (not $self->in_object_context)
        || Paxton::Core::Exception->new( message => 'Unable to enter array context from within object context (must be in property context)' )->throw;

    push @$self => { type => IN_ARRAY, value => $value, item_count => 0 };
    return;
}

sub enter_property_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter property context: stack is empty' )->throw;

    ($self->in_object_context)
        || Paxton::Core::Exception->new( message => 'Unable to enter property context from within anything but object context' )->throw;

    # increment the property counter
    $self->[-1]->{property_count}++;

    push @$self => { type => IN_PROPERTY, value => $value };
    return;
}

sub enter_item_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter item context: stack is empty' )->throw;

    ($self->in_array_context)
        || Paxton::Core::Exception->new( message => 'Unable to enter item context from within anything but array context' )->throw;

    # increment the property counter
    $self->[-1]->{item_count}++;

    push @$self => { type => IN_ITEM, value => $value };
    return;
}

# leave

sub leave_object_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->{type} == IN_OBJECT)
        || Paxton::Core::Exception->new( message => 'Must be in `object` context, not '.$self->[-1]->{type} )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_array_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->{type} == IN_ARRAY)
        || Paxton::Core::Exception->new( message => 'Must be in `array` context, not '.$self->[-1]->{type} )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_property_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->{type} == IN_PROPERTY)
        || Paxton::Core::Exception->new( message => 'Must be in `property` context, not '.$self->[-1]->{type} )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_item_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->{type} == IN_ITEM)
        || Paxton::Core::Exception->new( message => 'Must be in `item` context, not '.$self->[-1]->{type} )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->{value};
}

sub leave_current_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

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
