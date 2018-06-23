package Paxton::Streaming::API::Producer;
# ABSTRACT: One stop for all your JSON needs
use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub produce_token;
sub is_exhausted;

sub broadcast_one {
    my ($self, @consumers) = @_;
    my $token = $self->produce_token;
    return unless defined $token;
    $_->consume_token( $token ) foreach @consumers;
    return $token;
}

sub broadcast {
    my ($self, @consumers) = @_;
    #warn "Running...";
    until ( $self->is_exhausted || (scalar @consumers == 0) ) {
        #warn "broadcasting ...";
        last unless $self->broadcast_one( @consumers );
        #warn "got consumers : " . join ', ' => @consumers;
        @consumers = grep not($_->is_full), @consumers;
        #warn "got (filtered) consumers : " . join ', ' => @consumers;
        #warn '---------------------------------';
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
