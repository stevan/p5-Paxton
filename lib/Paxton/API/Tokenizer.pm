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

    until ( $producer->is_exhausted || $consumer->is_full ) {
        my $token = $producer->produce_token;
        last unless defined $token;
        $consumer->consume_token( $token );
    }

    until ( $producer->is_exhausted || $consumer->is_full ) {
        last unless $producer->process_token( $consumer );
    }

    $producer->process( $consumer );
    $consumer->consume( $producer );


=head1 DESCRIPTION

=cut
