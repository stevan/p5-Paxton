package Paxton::Streaming::Pipe::Map;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Paxton::Streaming::Pipe;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use constant DEBUG => $ENV{PAXTON_PIPE_MAP_DEBUG} // 0;

# ...

our @ISA; BEGIN { @ISA  = ('Paxton::Streaming::Pipe') }
our %HAS;  BEGIN {
    %HAS = (
        %Paxton::Streaming::Pipe::HAS,
        processor => sub { die 'You must specify a function using the `processor` key' },
    )
}

sub process_token {
    my ($self) = @_;
    my $token = $self->get_token;
    return if not defined $token;
    $token = $self->{processor}->( $self, $token );
    return if not defined $token;
    $self->put_token( $token )
        if defined $token;
}

1;

__END__

=pod

=cut
