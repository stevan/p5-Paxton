package Paxton::Schema::Type::Boolean;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use Paxton::Schema::Error::BadInput;
use Paxton::Schema::Error::BadType;
use Paxton::Schema::Error::BadValue;

extends 'Moxie::Object::Immutable';
   with 'Paxton::Schema::API::Type';

sub name { 'boolean' }

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
            if ( ref $value ne 'SCALAR' ) {
                push @errors => Paxton::Schema::Error::BadType->new( got => ref($value), expected => $self );
            }
            else {
                push @errors => Paxton::Schema::Error::BadValue->new( got => sprintf('\%s' => $value->$*), expected => $self )
                    unless $value->$* == 1
                        || $value->$* == 0;
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
