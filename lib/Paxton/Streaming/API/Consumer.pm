package Paxton::Streaming::API::Consumer;
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
    return $token;
}

sub consume {
    my ($self, $producer) = @_;
    # Ideally a producer and consumer will be
    # exhausted and full respectively at the
    # same time. But if that is not the case,
    # then we check producer first, because
    # there is no sense in consuming nothing
    until ( $producer->is_exhausted || $self->is_full ) {
        last unless $self->consume_one( $producer );
    }
    # return self for optional chaining
    return $self;
}

1;

__END__

=pod

=head1 SYNOPSIS

    my $producer  = ...;
    my $consumer  = ...;

    ## process one token at a time, manually

    until ( $producer->is_exhausted || $consumer->is_full ) {
        my $token = $producer->produce_token;
        last unless defined $token;
        $consumer->consume_token( $token );
    }

    ## let the consumer drive the producer

    # one at a time ...
    until ( $producer->is_exhausted || $consumer->is_full ) {
        last unless $consumer->consume_one( $producer );
    }

    # or the whole thing at once ...
    $consumer->consume( $producer );

    ## or be producer centric and broadcast
    ## to multiple consumers at once

    my @consumers = ($consumer, ...);

    # broadcast a token at a time to
    # mutliple consumers ...
    until ( $producer->is_exhausted || (scalar @consumers == 0) ) {
        last unless $producer->broadcast_one( @consumers );
        @consumers = grep not($_->is_full), @consumers;
    }

    # or the whole thing at once ...
    $producer->broadcast( @consumers );


=head1 DESCRIPTION

=cut
