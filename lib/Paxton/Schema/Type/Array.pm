package Paxton::Schema::Type::Array;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadInput;
use Paxton::Schema::Error::BadType;
use Paxton::Schema::Error::BadSize;

use UNIVERSAL::Object::Immutable;

use Paxton::Schema::API::Type;

our @ISA;  BEGIN { @ISA  = ('UNIVERSAL::Object::Immutable') }
our @DOES; BEGIN { @DOES = ('Paxton::Schema::API::Type') }
our %HAS;  BEGIN {
    %HAS = (
        items           => sub {},
        additionalItems => sub {},
        maxItems        => sub {},
        minItems        => sub {},
        uniqueItems     => sub {},
    );
}

sub name { 'array' }

sub validate {
    my ($self, $value) = @_;

    my @errors;

    if ( not defined $value ) {
        push @errors => Paxton::Schema::Error::BadInput->new( expected => $self );
    }
    else {
        if ( not ref $value ) {
            push @errors => Paxton::Schema::Error::BadType->new( got => $value, expected => $self );
        }
        else {
            if ( ref $value ne 'ARRAY' ) {
                push @errors => Paxton::Schema::Error::BadType->new( got => ref($value), expected => $self );
            }
            else {
                my $num_items = scalar @$value;

                if ( defined $self->{minItems} && not defined $self->{maxItems} ) {
                    push @errors => Paxton::Schema::Error::BadSize->new(
                        got      => $num_items,
                        expected => sprintf 'min: %d' => $self->{'minItems'},
                    ) if $num_items < $self->{minItems};
                }
                elsif ( defined $self->{maxItems} && not defined $self->{minItems} ) {
                    push @errors => Paxton::Schema::Error::BadSize->new(
                        got      => $num_items,
                        expected => sprintf 'max: %d' => $self->{'maxItems'},
                    ) if $num_items > $self->{maxItems};
                }
                elsif ( defined $self->{maxItems} && defined $self->{minItems} ) {
                    push @errors => Paxton::Schema::Error::BadSize->new(
                        got      => $num_items,
                        expected => sprintf 'min: %d, max: %d' => @{$self}{qw[ minItems maxItems ]},
                    ) if $num_items < $self->{minItems}
                      || $num_items > $self->{maxItems};
                }

                # TODO:
                # - uniqueItems
            }
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
