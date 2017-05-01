package Paxton::Schema::Type::Integer;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Scalar::Util ();

use Paxton::Schema::Error::ExceedsRange;
use Paxton::Schema::Error::BadInput;
use Paxton::Schema::Error::BadType;

extends 'Moxie::Object::Immutable';
   with 'Paxton::Schema::API::Type';

has 'multipleOf';
has 'maximum';
has 'exclusiveMaximum';
has 'minimum';
has 'exclusiveMinimum';

sub name { 'integer' }

sub validate ($self, $value) {
    my @errors;

    if ( not defined $value ) {
        push @errors => Paxton::Schema::Error::BadInput->new( expected => $self );
    }
    else {
        if ( ref $value ) {
            push @errors => Paxton::Schema::Error::BadType->new( got => ref($value), expected => $self );
        }
        elsif ( not Scalar::Util::looks_like_number($value) && int( $value ) == $value ) {
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

1;

__END__

=pod

=cut
