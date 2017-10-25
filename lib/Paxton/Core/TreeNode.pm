package Paxton::Core::TreeNode;
# ABSTRACT: One stop for all your JSON needs
use Moxie;
use Moxie::Enum;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use constant DEBUG => $ENV{PAXTON_PARSER_DEBUG} // 0;

## constants

enum NodeType => qw[
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

extends 'Moxie::Object::Immutable';

## slots

has '_type'     => sub { die 'A `type` is required' };
has '_children' => sub { +[] };
has '_value';

my sub _type     : private;
my sub _children : private;
my sub _value    : private;

## constructor

sub BUILDARGS : init_args(
    type      => _type,
    value?    => _value,
    children? => _children,
);

sub type     : ro('_type');
sub children : ro('_children');
sub value    : ro('_value');

# cheap serializer
sub to_string ($self) {
    #use Data::Dumper;
    #warn Dumper $self;

    my $type = _type;

    if ( $type == OBJECT ) {
        return '{' . (join ',' => map $_->to_string, _children->@*) . '}';
    }
    elsif ( $type == PROPERTY ) {
        return '"' . _value . '":' . _children->[0]->to_string;
    }
    elsif ( $type == ARRAY ) {
        return '[' . (join ',' => map $_->to_string, _children->@*) . ']';
    }
    elsif ( $type == ITEM ) {
        return _children->[0]->to_string;
    }
    elsif ( $type == STRING ) {
        return '"' . _value . '"';
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
        return _value;
    }

    return;
}

1;

__END__

=pod

=cut
