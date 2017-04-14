package Paxton::API::Tokenizer::Consumer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub consume_token;
sub is_full;

sub consume_one {
    my ($self, $producer) = @_;
    my $token = $producer->produce_token;
    return unless defined $token;
    $self->consume_token( $token );
    return 1;
}

sub consume {
    my ($self, $producer) = @_;
    until ( $producer->is_exhausted || $self->is_full ) {
        last unless $self->consume_one( $producer );
    }
}

1;

__END__

=pod

=head1 DESCRIPTION

=cut
