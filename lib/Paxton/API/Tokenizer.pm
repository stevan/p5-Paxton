package Paxton::API::Tokenizer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

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
