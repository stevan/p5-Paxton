package Paxton::Schema::API::Error;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

our %HAS; BEGIN {
    %HAS = (
        got      => sub {},
        expected => sub {},
    );
}

sub message {
    my ($self, $format) = @_;

    $format //= 'Error(%s) - got: (%s) expected: (%s)';

    sprintf $format => (
        (split /\:\:/ => ref $self)[-1],
        map {
            Scalar::Util::blessed( $_ ) && $_->can('name')
                ? $_->name
                : defined $_
                    ? "$_"
                    : 'undef'
        } @{$self}{qw[ got expected ]}
    );
}

1;

__END__
