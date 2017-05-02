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

has 'type'     => sub { die 'A `type` is required' };
has 'children' => sub { +[] };
has 'value';

sub type     : ro;
sub children : ro;
sub value    : ro;

# cheap serializer
sub to_string ($self) {
    #use Data::Dumper;
    #warn Dumper $self;

    my $type = $self->{type};

    if ( $type == OBJECT ) {
        return '{' . (join ',' => map $_->to_string, $self->{children}->@*) . '}';
    }
    elsif ( $type == PROPERTY ) {
        return '"' . $self->{value} . '":' . $self->{children}->[0]->to_string;
    }
    elsif ( $type == ARRAY ) {
        return '[' . (join ',' => map $_->to_string, $self->{children}->@*) . ']';
    }
    elsif ( $type == ITEM ) {
        return $self->{children}->[0]->to_string;
    }
    elsif ( $type == STRING ) {
        return '"' . $self->{value} . '"';
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
        return $self->{value};
    }
}

1;

__END__

=pod

=cut
