package Paxton::Core::TreeNode;
# ABSTRACT: One stop for all your JSON needs
use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':constructor', ':accessors';

use constant DEBUG => $ENV{PAXTON_PARSER_DEBUG} // 0;

use enumerable NodeType => qw[
    OBJECT
    PROPERTY
    ARRAY
    ITEM
    STRING
    INT
    FLOAT
    TRUE
    FALSE
    NULL
];

# ...

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    _type     => sub { die 'A `type` is required' },
    _children => sub { +[] },
    _value    => sub {},
);

## constructor

sub BUILDARGS : strict(
    type      => _type,
    value?    => _value,
    children? => _children,
);

sub type     : ro(_);
sub children : ro(_);
sub value    : ro(_);

# cheap serializer
sub to_string {
    my ($self) = @_;
    #use Data::Dumper;
    #warn Dumper $self;

    my $type = $self->{_type};

    if ( $type == OBJECT ) {
        return '{' . (join ',' => map $_->to_string, @{ $self->{_children} }) . '}';
    }
    elsif ( $type == PROPERTY ) {
        return '"' . $self->{_value} . '":' . $self->{_children}->[0]->to_string;
    }
    elsif ( $type == ARRAY ) {
        return '[' . (join ',' => map $_->to_string, @{ $self->{_children} }) . ']';
    }
    elsif ( $type == ITEM ) {
        return $self->{_children}->[0]->to_string;
    }
    elsif ( $type == STRING ) {
        return '"' . $self->{_value} . '"';
    }
    elsif ( $type == TRUE ) {
        return 'true';
    }
    elsif ( $type == FALSE ) {
        return 'false';
    }
    elsif ( $type == NULL ) {
        return 'null';
    }
    else {
        return $self->{_value};
    }

    return;
}

1;

__END__

=pod

=cut
