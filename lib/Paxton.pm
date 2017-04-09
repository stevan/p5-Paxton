package Paxton;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

1;

__END__

=pod

=head1 SYNOPSIS

=head1 DESCRIPTION

One stop for all your JSON needs.

=head2 L<Paxton::Core::API::Token::Producer>

These classes produce a token stream by calling the C<get_token>
method in a loop until the C<is_exhausted> method returns true.

=over 4

=item L<Paxton::Streaming::Reader>

Convert a JSON string into a stream of tokens.

=item L<Paxton::Streaming::Encoder>

Convert an in-memory data structure into a stream of tokens.

=back

=head2 L<Paxton::Core::API::Token::Consumer>

These classes consume a token stream by feedins tokens to the
C<put_token> method in a loop until the C<is_full> method returns
true.

=over 4

=item L<Paxton::Streaming::Writer>

Convert a stream of tokens into a JSON string.

=item L<Paxton::Streaming::Decoder>

Convert a stream of tokens into an in-memory data structure.

=item L<Paxton::Streaming::Parser>

Convert a stream of tokens into a L<Paxton::Core::TreeNode> tree.

=back

=head1 SEE ALSO

=head2 What kind of name is Paxton?

So this is largely inspired by the Jackson Java library, so
I was looking for a name similar to that, but distinct. The
Python port is called (wait for it), Pyckson and the Ruby
port is called Rackson, so for sure I didn't want to call it
Perkson, but Packson kind of worked. Then I remembered that
Bill Paxton died recently and since I grew watching his
movies I figured, why not!

L<https://en.wikipedia.org/wiki/Bill_Paxton>

=cut
