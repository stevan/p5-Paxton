package Paxton::Core::JSONToken;

use strict;
use warnings;

use Scalar::Util;

our $VERSION = '0.01';

our ( @EXPORTS, %TOKEN_MAP );
BEGIN {
    my $idx = 1;
    %TOKEN_MAP = (
        NOT_AVAILABLE  => Scalar::Util::dualvar( -1,     'NOT_AVAILABLE'  ),
        NO_TOKEN       => Scalar::Util::dualvar( 0,      'NO_TOKEN'       ),

        START_OBJECT   => Scalar::Util::dualvar( $idx++, 'START_OBJECT'   ),
        END_OBJECT     => Scalar::Util::dualvar( $idx++, 'END_OBJECT'     ),

        START_PROPERTY => Scalar::Util::dualvar( $idx++, 'START_PROPERTY' ),
        END_PROPERTY   => Scalar::Util::dualvar( $idx++, 'END_PROPERTY'   ),

        START_ARRAY    => Scalar::Util::dualvar( $idx++, 'START_ARRAY'    ),
        END_ARRAY      => Scalar::Util::dualvar( $idx++, 'END_ARRAY'      ),

        ADD_STRING     => Scalar::Util::dualvar( $idx++, 'ADD_STRING'     ),
        ADD_INT        => Scalar::Util::dualvar( $idx++, 'ADD_INT'        ),
        ADD_FLOAT      => Scalar::Util::dualvar( $idx++, 'ADD_FLOAT'      ),

        ADD_TRUE       => Scalar::Util::dualvar( $idx++, 'ADD_TRUE'       ),
        ADD_FALSE      => Scalar::Util::dualvar( $idx++, 'ADD_FALSE'      ),
        ADD_NULL       => Scalar::Util::dualvar( $idx++, 'ADD_NULL'       ),

        ERROR          => Scalar::Util::dualvar( $idx++, 'ERROR'          ),
    );

    @EXPORTS = keys %TOKEN_MAP;

    foreach my $name ( keys %TOKEN_MAP ) {
        no strict 'refs';
        *{$name} = sub { $TOKEN_MAP{ $name } };
    }
}

sub import { (shift)->import_into( scalar caller, @_ ) }

sub import_into {
    my (undef, $into, @exports) = @_;
    @exports = @EXPORTS unless @exports;
    no strict 'refs';
    *{$into.'::'.$_} = \&{$_} foreach @exports;
}

1;

__END__

=pod

=head1 TOKENS

=head2 C<NOT_AVAILABLE>

=head2 C<NO_TOKEN>

=head2 C<START_OBJECT>

=head2 C<END_OBJECT>

=head2 C<START_PROPERTY>

=head2 C<END_PROPERTY>

=head2 C<START_ARRAY>

=head2 C<END_ARRAY>

=head2 C<ADD_STRING>

=head2 C<ADD_INT>

=head2 C<ADD_FLOAT>

=head2 C<ADD_TRUE>

=head2 C<ADD_FALSE>

=head2 C<ADD_NULL>

=head2 C<ERROR>

=cut
