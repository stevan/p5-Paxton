package Paxton::Core::Pointer;
# ABSTRACT: A representation of a JSON Pointer path
use strict;
use warnings;

use Paxton::Util::Errors;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use decorators ':accessors';

use constant DEBUG => $ENV{PAXTON_POINTER_DEBUG} // 0;

use enumerable PathSegmentType => qw[
    PROPERTY
    ITEM
];
# leave room for other possibilities here:
# REGEX => ... match a regex against keys ...
# RANGE => ... match a range of items ...
# GLOB  => ... match everything in between ...

# ...

use parent 'UNIVERSAL::Object::Immutable';
use slots (
    path => sub { die 'You must specify the `path` you want to point to.' }
);

## constructor

sub BUILDARGS {
    my ($class, @args) = @_;
    # if we just get a single string,
    # then handle it accordingly
    @args = ( path => $args[0] )
        if scalar @args == 1 && not ref $args[0];

    my $args = $class->SUPER::BUILDARGS( @args );

    ($args->{path} =~ /^\//)
        || throw('Pointer path must start with a `/`');

    return $args;
}

## methods

sub path : ro;

sub path_segments {
    return map s/~1/\//r, #/
           map s/~0/\~/r, #/
           grep defined $_ && $_ ne '',
           split /\// => $_[0]->path;
}

sub length { scalar $_[0]->path_segments }

sub tokenize {
    return map {
        /^\d$/ ? [ ITEM,     $_ ]
               : [ PROPERTY, $_ ]
    } $_[0]->path_segments;
}

1;

__END__

=pod

=head1 SEE ALSO

L<https://tools.ietf.org/html/rfc6901>

=cut

