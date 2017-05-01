package Paxton::Core::Token;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Scalar::Util ();
use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use constant DEBUG => $ENV{PAXTON_TOKEN_DEBUG} // 0;

# constants

our %TOKEN_MAP;
BEGIN {
    %TOKEN_MAP = (
        NOT_AVAILABLE  => Scalar::Util::dualvar( -1, 'NOT_AVAILABLE'  ),
        NO_TOKEN       => Scalar::Util::dualvar( 0,  'NO_TOKEN'       ),

        START_OBJECT   => Scalar::Util::dualvar( 1,  'START_OBJECT'   ),
        END_OBJECT     => Scalar::Util::dualvar( 2,  'END_OBJECT'     ),

        START_PROPERTY => Scalar::Util::dualvar( 3,  'START_PROPERTY' ),
        END_PROPERTY   => Scalar::Util::dualvar( 4,  'END_PROPERTY'   ),

        START_ARRAY    => Scalar::Util::dualvar( 5,  'START_ARRAY'    ),
        END_ARRAY      => Scalar::Util::dualvar( 6,  'END_ARRAY'      ),

        START_ITEM     => Scalar::Util::dualvar( 7,  'START_ITEM'     ),
        END_ITEM       => Scalar::Util::dualvar( 8,  'END_ITEM'       ),

        ADD_STRING     => Scalar::Util::dualvar( 9,  'ADD_STRING'     ),
        ADD_INT        => Scalar::Util::dualvar( 10, 'ADD_INT'        ),
        ADD_FLOAT      => Scalar::Util::dualvar( 11, 'ADD_FLOAT'      ),

        ADD_TRUE       => Scalar::Util::dualvar( 12, 'ADD_TRUE'       ),
        ADD_FALSE      => Scalar::Util::dualvar( 13, 'ADD_FALSE'      ),
        ADD_NULL       => Scalar::Util::dualvar( 14, 'ADD_NULL'       ),

        ERROR          => Scalar::Util::dualvar( 15, 'ERROR'          ),
    );

    foreach my $name ( keys %TOKEN_MAP ) {
        no strict 'refs';
        *{$name} = sub (@) { $TOKEN_MAP{ $name } };
    }
}

# ...

extends 'Moxie::Object::Immutable';

has 'type' => sub { die 'A `type` is required' };
has 'value';

# ...

sub BUILD ($self, $) {
    (exists $TOKEN_MAP{ $self->{type} })
        || throw('Unknown token type (' . $self->{type} . ')' );

    # XXX
    # Might want to check which kinds of
    # tokens require values and which do
    # not, and then verify accordingly.
    # - SL
}

# ...

sub type  : ro;
sub value : ro;

sub has_value : predicate;

sub dump ($self) {
    require Data::Dumper;
    Data::Dumper::Dumper( $self );
}

sub to_string ($self) {
    my $out  = 'token( '.$self->{type};

    if ( defined $self->{value} ) {
        my $needs_quotes = $self->{type} == ADD_STRING || $self->{type} == START_PROPERTY;

        $out .= ', '
             .($needs_quotes ? '\'' : '')
             .$self->{value}
             .($needs_quotes ? '\'' : '');
    }
    return $out.' )';
}

1;

__END__

=pod

=cut
