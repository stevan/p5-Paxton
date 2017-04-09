package Paxton::API::Token;
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
    my $processer = ...;

    until ( $producer->is_exhausted || $consumer->is_full ) {
        $consumer->put_token(
            $processer->process_token(
                $producer->get_token
            )
        );
    }

=head1 DESCRIPTION

=cut
