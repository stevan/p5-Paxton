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
our %HAS; BEGIN {
    %HAS = (
        stack => sub { +[] },
    )
}

# predicates

sub in_root_context   {
    my ($self) = @_;
    return unless scalar @{ $_[0]->{stack} } && defined $_[0]->{stack}->[-1];
    return $_[0]->{stack}->[-1]->[0] == ROOT;
}

sub in_object_context   {
    my ($self) = @_;
    return unless scalar @{ $_[0]->{stack} } && defined $_[0]->{stack}->[-1];
    return $_[0]->{stack}->[-1]->[0] == IN_OBJECT;
}

sub in_array_context    {
    my ($self) = @_;
    return unless scalar @{ $_[0]->{stack} } && defined $_[0]->{stack}->[-1];
    return $_[0]->{stack}->[-1]->[0] == IN_ARRAY;
}

sub in_property_context {
    my ($self) = @_;
    return unless scalar @{ $_[0]->{stack} } && defined $_[0]->{stack}->[-1];
    return $_[0]->{stack}->[-1]->[0] == IN_PROPERTY;
}

# enter ...

sub enter_root_context   {
    my ($self, $exit_handler) = @_;

    (scalar @{ $self->{stack} } == 0)
        || Paxton::Core::Exception->new( message => 'Unable to enter root context: stack not empty' )->throw;

    push @{ $self->{stack} } => [ ROOT, $exit_handler ];
    return;
}

sub enter_object_context   {
    my ($self, $exit_handler) = @_;

    (scalar @{ $self->{stack} })
        || Paxton::Core::Exception->new( message => 'Unable to enter object context: stack is empty' )->throw;

    push @{ $self->{stack} } => [ IN_OBJECT, $exit_handler ];
    return;
}

sub enter_array_context    {
    my ($self, $exit_handler) = @_;

    (scalar @{ $self->{stack} })
        || Paxton::Core::Exception->new( message => 'Unable to enter array context: stack is empty' )->throw;

    push @{ $self->{stack} } => [ IN_ARRAY, $exit_handler ];
    return;
}

sub enter_property_context {
    my ($self, $exit_handler) = @_;

    (scalar @{ $self->{stack} })
        || Paxton::Core::Exception->new( message => 'Unable to enter property context: stack is empty' )->throw;

    push @{ $self->{stack} } => [ IN_PROPERTY, $exit_handler ];
    return;
}

# leave

sub leave_current_context {
    my ($self) = @_;

    (scalar @{ $self->{stack} })
        || Paxton::Core::Exception->new( message => 'Unable to leave context: stack exhausted' )->throw;

    pop @{ $self->{stack} };

    # return nothing if we got nothing ...
    return unless scalar @{ $_[0]->{stack} };
    # otherwise restore the previous context ...
    return $_[0]->{stack}->[-1]->[1];
}

1;

__END__

=pod

=cut
