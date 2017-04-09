package Paxton::Core::TreeNode;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();
use UNIVERSAL::Object::Immutable;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use constant DEBUG => $ENV{PAXTON_PARSER_DEBUG} // 0;

## constants

our %TYPE_MAP;
BEGIN {
    %TYPE_MAP = (
        OBJECT   => Scalar::Util::dualvar( 1, 'OBJECT'   ),
        PROPERTY => Scalar::Util::dualvar( 2, 'PROPERTY' ),
        ARRAY    => Scalar::Util::dualvar( 3, 'ARRAY'    ),
        STRING   => Scalar::Util::dualvar( 4, 'STRING'   ),
        INT      => Scalar::Util::dualvar( 5, 'INT'      ),
        FLOAT    => Scalar::Util::dualvar( 6, 'FLOAT'    ),
        TRUE     => Scalar::Util::dualvar( 7, 'TRUE'     ),
        FALSE    => Scalar::Util::dualvar( 8, 'FALSE'    ),
        NULL     => Scalar::Util::dualvar( 9, 'NULL'     ),
    );

    foreach my $name ( keys %TYPE_MAP ) {
        no strict 'refs';
        *{$name} = sub () { $TYPE_MAP{ $name } };
    }
}

# ...

our @ISA; BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        type     => sub { die 'A `type` is required' },
        value    => sub {},
        children => sub { +[] }
    )
}

sub type     { $_[0]->{type}     }
sub value    { $_[0]->{value}    }
sub children { $_[0]->{children} }

# NOTE:
# this doesn't actually make sense, we
# actually want to be able to conver this
# into a token-stream, but that is
# trickier.
# - SL
sub to_string {
    my $self = $_[0];

    #use Data::Dumper;
    #warn Dumper $self;

    my $type = $self->{type};

    if ( $type == OBJECT ) {
        return '{' . (join ',' => map $_->to_string, @{$self->{children}}) . '}';
    }
    elsif ( $type == PROPERTY ) {
        return '"' . $self->{value} . '":' . $self->{children}->[0]->to_string;
    }
    elsif ( $type == ARRAY ) {
        return '[' . (join ',' => map $_->to_string, @{$self->{children}}) . ']';
    }
    elsif ( $type == STRING ) {
        return '"' . $self->value . '"';
    }
    else {
        return $self->value;
    }
}

1;

__END__

=pod

=cut