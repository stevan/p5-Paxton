package Paxton::Schema::Util::TypeConstraint;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use UNIVERSAL::Object;

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }
our %HAS; BEGIN {
    %HAS = (
        type    => sub { die 'You must specify a `type` to wrap.' },
        # private ...
        _message  => sub {},
        _compiled => sub {},
    );
}

sub name { $_[0]->{type}->name }

sub validate {
    my ($self, $value) = @_;
    # ask the type ...
    my @errors = $self->{type}->validate( $value );
    # horray, it worked!
    return undef if scalar @errors == 0;
    # stash errors here ...
    $self->{_message} = join '; ' => map $_->message, @errors;
    # and return false
    return $self->{_message};
}

sub check {
    my ($self, $value) = @_;
    # if &validate returns undef then
    # we passed successfully, so convert
    # this into a boolean
    return not defined $self->validate( $value );
}

sub has_coercion       { 0 }
sub can_be_inlined     { 0 }
sub inline_environment { {} }

sub has_message      { !! $_[0]->{_message} }
sub get_message      {    $_[0]->{_message} }
sub _default_message {    $_[0]->{_message} //= ($_[0]->{type}->name . ' - Validation Error') }

sub _compiled_type_constraint {
    my ($self) = @_;
    return $self->{_compiled} ||= sub { return $self->check( $_[0] ) };
}

1;

__END__
