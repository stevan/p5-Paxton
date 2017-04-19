package Paxton::Schema::Type::Null;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadValue;

use UNIVERSAL::Object::Immutable;

use Paxton::Schema::API::Type;

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our @DOES; BEGIN { @DOES = ('Paxton::Schema::API::Type') }
our %HAS;  BEGIN {
    %HAS = (

    );
}

sub name { 'null' }

sub validate {
    my ($self, $value) = @_;

    my @errors;

    if ( defined $value ) {
        push @errors => Paxton::Schema::Error::BadValue->new( got => $value, expected => $self );
    }

    return @errors if @errors;
    return;
}

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
