package Paxton::Schema::Type::String;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadInput;
use Paxton::Schema::Error::BadType;
use Paxton::Schema::Error::BadLength;

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

sub name { 'string' }

sub validate {
    my ($self, $value) = @_;

    my @errors;

    if ( not defined $value ) {
        push @errors => Paxton::Schema::Error::BadInput->new( expected => $self );
    }
    else {
        if ( ref $value ) {
            push @errors => Paxton::Schema::Error::BadType->new( got => ref($value), expected => $self );
        }
        else {
            if ( defined $self->{minLength} && not defined $self->{maxLength} ) {
                push @errors => Paxton::Schema::Error::BadLength->new(
                    got      => length($value),
                    expected => sprintf 'min: %d' => $self->{'minLength'},
                ) if length($value) < $self->{minLength};
            }
            elsif ( defined $self->{maxLength} && not defined $self->{minLength} ) {
                push @errors => Paxton::Schema::Error::BadLength->new(
                    got      => length($value),
                    expected => sprintf 'max: %d' => $self->{'maxLength'},
                ) if length($value) > $self->{maxLength};
            }
            elsif ( defined $self->{maxLength} && defined $self->{minLength} ) {
                push @errors => Paxton::Schema::Error::BadLength->new(
                    got      => length($value),
                    expected => sprintf 'min: %d, max: %d' => @{$self}{qw[ minLength maxLength ]},
                ) if length($value) < $self->{minLength}
                  || length($value) > $self->{maxLength};
            }

            # TODO:
            # - check pattern
            # - check format
        }
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
