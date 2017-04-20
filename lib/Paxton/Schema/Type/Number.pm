package Paxton::Schema::Type::Number;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

use Paxton::Schema::Error::ExceedsRange;
use Paxton::Schema::Error::BadInput;
use Paxton::Schema::Error::BadType;

use UNIVERSAL::Object::Immutable;

use Paxton::Schema::API::Type;

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our @DOES; BEGIN { @DOES = ('Paxton::Schema::API::Type') }
our %HAS;  BEGIN {
    %HAS = (
        multipleOf       => sub {},
        maximum          => sub {},
        exclusiveMaximum => sub {},
        minimum          => sub {},
        exclusiveMinimum => sub {},
    );
}

sub name { 'number' }

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
        elsif ( not Scalar::Util::looks_like_number($value) ) {
            push @errors => Paxton::Schema::Error::BadType->new( got => $value, expected => $self );
        }
        else {
            if ( defined $self->{minimum} && not defined $self->{maximum} ) {
                push @errors => Paxton::Schema::Error::ExceedsRange->new(
                    got      => $value,
                    expected => sprintf 'min: %d' => $self->{'minimum'},
                ) if $value < $self->{minimum};
            }
            elsif ( defined $self->{maximum} && not defined $self->{minimum} ) {
                push @errors => Paxton::Schema::Error::ExceedsRange->new(
                    got      => $value,
                    expected => sprintf 'max: %d' => $self->{'maximum'},
                ) if $value > $self->{maximum};
            }
            elsif ( defined $self->{maximum} && defined $self->{minimum} ) {
                push @errors => Paxton::Schema::Error::ExceedsRange->new(
                    got      => $value,
                    expected => sprintf 'min: %d, max: %d' => @{$self}{qw[ minimum maximum ]},
                ) if $value < $self->{minimum}
                  || $value > $self->{maximum};
            }

            # TODO:
            # - check exclusive{Min,Max}imum
            # - check multipleOf
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
