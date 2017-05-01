package Paxton::Schema::Type::Array;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadInput;
use Paxton::Schema::Error::BadType;
use Paxton::Schema::Error::BadSize;

extends 'Moxie::Object::Immutable';
   with 'Paxton::Schema::API::Type';

has 'items';
has 'additionalItems';
has 'maxItems';
has 'minItems';
has 'uniqueItems';

sub name { 'array' }

sub validate ($self, $value) {
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
                my $num_items = scalar $value->@*;

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

1;

__END__

=pod

=cut
