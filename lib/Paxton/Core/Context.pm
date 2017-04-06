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

# constructor ...

sub new {
    my ($class) = @_;
    return bless [] => $class;
}

# ...

sub depth { scalar @{ $_[0] } }

sub current_context_value { $_[0]->[-1]->[1] }

# predicates

sub in_root_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->[0] == ROOT;
}

sub in_object_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->[0] == IN_OBJECT;
}

sub in_array_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->[0] == IN_ARRAY;
}

sub in_property_context {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->[0] == IN_PROPERTY;
}

# enter ...

sub enter_root_context {
    my ($self, $value) = @_;

    (scalar @$self == 0)
        || Paxton::Core::Exception->new( message => 'Unable to enter root context: stack not empty' )->throw;

    push @$self => [ ROOT, $value ];
    return;
}

sub enter_object_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter object context: stack is empty' )->throw;

    push @$self => [ IN_OBJECT, $value ];
    return;
}

sub enter_array_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter array context: stack is empty' )->throw;

    (not $self->in_object_context)
        || Paxton::Core::Exception->new( message => 'Unable to enter array context from within object context (must be in property context)' )->throw;

    push @$self => [ IN_ARRAY, $value ];
    return;
}

sub enter_property_context {
    my ($self, $value) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter property context: stack is empty' )->throw;

    ($self->in_object_context)
        || Paxton::Core::Exception->new( message => 'Unable to enter property context from within anything but object context' )->throw;

    push @$self => [ IN_PROPERTY, $value ];
    return;
}

# leave

sub leave_object_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->[0] == IN_OBJECT)
        || Paxton::Core::Exception->new( message => 'Must be in `object` context, not '.$self->[-1]->[0] )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->[1];
}

sub leave_array_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->[0] == IN_ARRAY)
        || Paxton::Core::Exception->new( message => 'Must be in `array` context, not '.$self->[-1]->[0] )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->[1];
}

sub leave_property_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    ($self->[-1]->[0] == IN_PROPERTY)
        || Paxton::Core::Exception->new( message => 'Must be in `property` context, not '.$self->[-1]->[0] )->throw;

    pop @$self;

    # return nothing if we got nothing ...
    return unless scalar @$self;
    # otherwise restore the previous context ...
    return $self->[-1]->[1];
}

1;

__END__

=pod

=cut
