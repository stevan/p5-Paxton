package Paxton::API::Tokenizer::Producer;
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
}

1;

__END__

=pod

=head1 DESCRIPTION

=cut
