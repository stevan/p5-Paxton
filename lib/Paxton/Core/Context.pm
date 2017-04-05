package Paxton::Core::Context;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();
use UNIVERSAL::Object;

use Paxton::Core::Exception;
use Paxton::Core::Tokens;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# contstants ...

use constant IN_OBJECT   => Scalar::Util::dualvar( 1, 'IN_OBJECT'   );
use constant IN_ARRAY    => Scalar::Util::dualvar( 2, 'IN_ARRAY'    );
use constant IN_PROPERTY => Scalar::Util::dualvar( 3, 'IN_PROPERTY' );

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        stack    => sub { +[] },
        handlers => sub { +{} },
    )
}

## constructors

sub new_with_handlers {
    my ($self, %handlers) = @_;
    $self->new( handlers => \%handlers );
}

# ...

# TODO:
# array bounds checking
# - SL

sub enter_object_context   { push @{ $_[0]->{stack} } => IN_OBJECT   }
sub enter_array_context    { push @{ $_[0]->{stack} } => IN_ARRAY    }
sub enter_property_context { push @{ $_[0]->{stack} } => IN_PROPERTY }

sub in_object_context   { $_[0]->{stack}->[-1] == IN_OBJECT   }
sub in_array_context    { $_[0]->{stack}->[-1] == IN_ARRAY    }
sub in_property_context { $_[0]->{stack}->[-1] == IN_PROPERTY }

sub current_context       { $_[0]->{stack}->[-1]    }
sub leave_current_context { pop @{ $_[0]->{stack} } }

sub restore_previous_context {
    my ($self) = @_;

    my $ctx = $self->{stack}->[-1];

    if ( not defined $ctx ) {
        return $self->{handlers}->{'__DEFAULT__'};
    }
    elsif ( $ctx == IN_OBJECT ) {
        return $self->{handlers}->{'IN_OBJECT'};
    }
    elsif ( $ctx == IN_ARRAY ) {
        return $self->{handlers}->{'IN_ARRAY'};
    }
    elsif ( $ctx == IN_PROPERTY ) {
        return $self->{handlers}->{'IN_PROPERTY'};
    }
}

1;

__END__

=pod

=cut
