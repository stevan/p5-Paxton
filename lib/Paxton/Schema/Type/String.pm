package Paxton::Schema::Type::String;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::API::Type;

use UNIVERSAL::Object::Immutable;

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our @DOES; BEGIN { @DOES = ('Paxton::Schema::API::Type') }
our %HAS;  BEGIN {
    %HAS = (
        maxLength => sub {},
        minLength => sub {},
        pattern   => sub {},
        format    => sub {},
    );
}

sub type { 'string' }

# ROLE COMPOSITON

BEGIN {
    use MOP::Role;
    use MOP::Internal::Util;

    MOP::Internal::Util::APPLY_ROLES(
        MOP::Role->new(name => __PACKAGE__),
        \@DOES,
        to => 'class'
    );
}

1;

__END__

=pod

=cut
