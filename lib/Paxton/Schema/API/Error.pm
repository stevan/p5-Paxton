package Paxton::Schema::API::Error;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

use Scalar::Util ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'got';
has 'expected';

sub message ($self, $format = 'Error(%s) - got: (%s) expected: (%s)') {
    sprintf $format => (
        (split /\:\:/ => ref $self)[-1],
        map {
            Scalar::Util::blessed( $_ ) && $_->can('name')
                ? $_->name
                : defined $_
                    ? "$_"
                    : 'undef'
        } @{ $self }{qw[ got expected ]}
    );
}

1;

__END__
