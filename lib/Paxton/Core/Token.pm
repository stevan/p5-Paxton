package Paxton::Core::Token;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();
use UNIVERSAL::Object::Immutable;

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use constant DEBUG => $ENV{PAXTON_TOKEN_DEBUG} // 0;

# constants

our %TOKEN_MAP;
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

        START_ITEM     => Scalar::Util::dualvar( $idx++, 'START_ITEM'     ),
        END_ITEM       => Scalar::Util::dualvar( $idx++, 'END_ITEM'       ),

        ADD_STRING     => Scalar::Util::dualvar( $idx++, 'ADD_STRING'     ),
        ADD_INT        => Scalar::Util::dualvar( $idx++, 'ADD_INT'        ),
        ADD_FLOAT      => Scalar::Util::dualvar( $idx++, 'ADD_FLOAT'      ),

        ADD_TRUE       => Scalar::Util::dualvar( $idx++, 'ADD_TRUE'       ),
        ADD_FALSE      => Scalar::Util::dualvar( $idx++, 'ADD_FALSE'      ),
        ADD_NULL       => Scalar::Util::dualvar( $idx++, 'ADD_NULL'       ),

        ERROR          => Scalar::Util::dualvar( $idx++, 'ERROR'          ),
    );

    foreach my $name ( keys %TOKEN_MAP ) {
        no strict 'refs';
        *{$name} = sub () { $TOKEN_MAP{ $name } };
    }
}

# ...

our @ISA; BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        type     => sub { die 'A `type` is required' },
        value    => sub {},
    )
}

# ...

sub BUILD {
    my $self = $_[0];

    (exists $TOKEN_MAP{ $self->{type} })
        || Paxton::Core::Exception->new( message => 'Unknown token type (' . $self->{type} . ')' )->throw;

    # XXX
    # Might want to check which kinds of
    # tokens require values and which do
    # not, and then verify accordingly.
    # - SL
}

# ...

sub type  { $_[0]->{type}  }
sub value { $_[0]->{value} }

sub dump {
    require Data::Dumper;
    Data::Dumper::Dumper( $_[0] );
}

sub as_string {
    my $out  = 'token( '.$_[0]->type;

    if ( defined $_[0]->value ) {
        my $needs_quotes = $_[0]->type == ADD_STRING || $_[0]->type == START_PROPERTY;

        $out .= ', '
             .($needs_quotes ? '\'' : '')
             .$_[0]->value
             .($needs_quotes ? '\'' : '');
    }
    return $out.' )';
}

1;

__END__

=pod

=cut
