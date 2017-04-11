package Paxton::Core::Pointer;
# ABSTRACT: A representation of a JSON Pointer path

use strict;
use warnings;

use UNIVERSAL::Object::Immutable;

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

# ...

use constant DEBUG => $ENV{PAXTON_POINTER_DEBUG} // 0;

# ...

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object::Immutable') }
our %HAS; BEGIN {
    %HAS = (
        path => sub { die 'You must specify the `path` you want to point to.' },
    )
}



sub BUILDARGS {
    my ($class, @args) = @_;

    # if we just get a single string,
    # then handle it accordingly
    @args = ( path => $args[0] )
        if scalar @args == 1 && not ref $args[0];

    my $args = $class->SUPER::BUILDARGS( @args );

    ($args->{path} =~ /^\//)
        || Paxton::Core::Exception->new( message => 'Pointer path must start with a `/`' )->throw;

    return $args;
}

sub path { $_[0]->{path} }

sub path_segments {
    my ($self) = @_;
    return map s/~1/\//r,
           map s/~0/\~/r,
           grep $_,
           split /\// => $_[0]->{path};
}

1;

__END__

=pod

=head1 SEE ALSO

L<https://tools.ietf.org/html/rfc6901>

=cut

