package Paxton::Parser::Node;
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

use constant OBJECT   => Scalar::Util::dualvar( 1, 'OBJECT'   );
use constant PROPERTY => Scalar::Util::dualvar( 2, 'PROPERTY' );
use constant ARRAY    => Scalar::Util::dualvar( 3, 'ARRAY'    );
use constant STRING   => Scalar::Util::dualvar( 4, 'STRING'   );
use constant INT      => Scalar::Util::dualvar( 5, 'INT'      );
use constant FLOAT    => Scalar::Util::dualvar( 6, 'FLOAT'    );
use constant TRUE     => Scalar::Util::dualvar( 7, 'TRUE'     );
use constant FALSE    => Scalar::Util::dualvar( 8, 'FALSE'    );
use constant NULL     => Scalar::Util::dualvar( 9, 'NULL'     );

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
