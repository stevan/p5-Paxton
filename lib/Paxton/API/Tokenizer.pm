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

    until ( $consumer->is_full || $producer->is_exhausted ) {
        my $token = $producer->produce_token;
        last unless defined $token;
        $consumer->consume_token( $token );
    }

    until ( $consumer->is_full || $producer->is_exhausted ) {
        last unless $consumer->consume_one( $producer );
    }

    $consumer->consume( $producer );


=head1 DESCRIPTION

=cut
