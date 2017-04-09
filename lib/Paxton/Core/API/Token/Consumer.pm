package Paxton::Core::API::Token::Consumer;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub put_token;
sub is_full;

1;

__END__

=pod

=head1 SYNOPSIS

    until ( $consumer->is_full ) {
        $consumer->put_token( get_next_token() );
    }

=head1 DESCRIPTION

=cut
