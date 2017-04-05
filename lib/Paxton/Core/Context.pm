package Paxton::Core::Context;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();
use UNIVERSAL::Object;

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# contstants ...

use constant ROOT        => Scalar::Util::dualvar( 1, 'ROOT'        );
use constant IN_OBJECT   => Scalar::Util::dualvar( 2, 'IN_OBJECT'   );
use constant IN_ARRAY    => Scalar::Util::dualvar( 3, 'IN_ARRAY'    );
use constant IN_PROPERTY => Scalar::Util::dualvar( 4, 'IN_PROPERTY' );

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

# use an array based instance here

sub REPR   { +[] }
sub CREATE { $_[0]->REPR }

# predicates

sub in_root_context   {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->[0] == ROOT;
}

sub in_object_context   {
    my ($self) = @_;
    return unless scalar @$self && defined $self->[-1];
    return $self->[-1]->[0] == IN_OBJECT;
}

sub in_array_context    {
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

sub enter_root_context   {
    my ($self, $exit_handler) = @_;

    (scalar @$self == 0)
        || Paxton::Core::Exception->new( message => 'Unable to enter root context: stack not empty' )->throw;

    push @$self => [ ROOT, $exit_handler ];
    return;
}

sub enter_object_context   {
    my ($self, $exit_handler) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter object context: stack is empty' )->throw;

    push @$self => [ IN_OBJECT, $exit_handler ];
    return;
}

sub enter_array_context    {
    my ($self, $exit_handler) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter array context: stack is empty' )->throw;

    push @$self => [ IN_ARRAY, $exit_handler ];
    return;
}

sub enter_property_context {
    my ($self, $exit_handler) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to enter property context: stack is empty' )->throw;

    push @$self => [ IN_PROPERTY, $exit_handler ];
    return;
}

# leave

sub leave_current_context {
    my ($self) = @_;

    (scalar @$self)
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

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
