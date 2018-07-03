package Paxton::Core::Token;
# ABSTRACT: One stop for all your JSON needs
use strict;
use warnings;

use Scalar::Util ();

use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use decorators ':accessors';

use constant DEBUG => $ENV{PAXTON_TOKEN_DEBUG} // 0;

# constants

use enumerable TokenType => {
    NOT_AVAILABLE  => -1,
    NO_TOKEN       => 0,

    START_OBJECT   => 1,
    END_OBJECT     => 2,

    START_PROPERTY => 3,
    END_PROPERTY   => 4,

    START_ARRAY    => 5,
    END_ARRAY      => 6,

    START_ITEM     => 7,
    END_ITEM       => 8,

    ADD_STRING     => 9,
    ADD_INT        => 10,
    ADD_FLOAT      => 11,

    ADD_TRUE       => 12,
    ADD_FALSE      => 13,
    ADD_NULL       => 14,

    ERROR          => 15,
};

# ...

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    type  => sub { die 'A `type` is required' },
    value => sub {},
);

# ...

sub BUILD {
    my ($self) = @_;
    (enumerable::has_value_for( ref $self, 'TokenType', $self->{type} ))
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

sub dump {
    my ($self) = @_;
    require Data::Dumper;
    Data::Dumper::Dumper( $self );
}

sub to_string {
    my ($self) = @_;

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
