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
        stack => sub { +[] },
    )
}

sub enter_object_context   { push @{ $_[0]->{state} } => IN_OBJECT   }
sub enter_array_context    { push @{ $_[0]->{state} } => IN_ARRAY    }
sub enter_property_context { push @{ $_[0]->{state} } => IN_PROPERTY }

sub current_context       { $_[0]->{state}->[-1]    }
sub leave_current_context { pop @{ $_[0]->{state} } }

1;

__END__

=pod

=cut
