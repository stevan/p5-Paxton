package Paxton::Core::API::Token::Producer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub get_token;
sub is_exhausted;

1;

__END__

=pod

=head1 SYNOPSIS

    until ( $producer->is_exhausted ) {
        process_token( $producer->get_token );
    }

=head1 DESCRIPTION

=cut
