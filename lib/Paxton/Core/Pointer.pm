package Paxton::Core::Pointer;
# ABSTRACT: A representation of a JSON Pointer path
use Moxie;
use Moxie::Enum;

use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use constant DEBUG => $ENV{PAXTON_POINTER_DEBUG} // 0;

# constants

enum PathSegmentType => qw[
    PROPERTY
    ITEM
];
# leave room for other possibilities here:
# REGEX => ... match a regex against keys ...
# RANGE => ... match a range of items ...
# GLOB  => ... match everything in between ...

# ...

extends 'Moxie::Object::Immutable';

has '$!path' => sub { die 'You must specify the `path` you want to point to.' };

# ...

sub BUILDARGS ($class, @args) {
    # if we just get a single string,
    # then handle it accordingly
    @args = ( path => $args[0] )
        if scalar @args == 1 && not ref $args[0];

    my $args = $class->next::method( @args );

    ($args->{path} =~ /^\//)
        || throw('Pointer path must start with a `/`' );

    $args->{'$!path'} = delete $args->{path};

    return $args;
}

sub path : ro('$!path');

sub path_segments ($self) {
    return map s/~1/\//r, #/
           map s/~0/\~/r, #/
           grep defined $_ && $_ ne '',
           split /\// => $self->path;
}

sub length ($self) { scalar $self->path_segments }

sub tokenize ($self) {
    return map {
        /^\d$/ ? [ ITEM,     $_ ]
               : [ PROPERTY, $_ ]
    } $self->path_segments;
}

1;

__END__

=pod

=head1 SEE ALSO

L<https://tools.ietf.org/html/rfc6901>

=cut

