package Paxton::Schema::Util::TypeConstraint;
# ABSTRACT: One stop for all your JSON needs
use Moxie;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moxie::Object';

has 'type' => sub { die 'You must specify a `type` to wrap.' },

# private ...
has '_message';
has '_compiled';

sub name : handles('type->name');

sub validate ($self, $value) {
    # ask the type ...
    my @errors = $self->{type}->validate( $value );
    # horray, it worked!
    return undef if scalar @errors == 0;
    # stash errors here ...
    $self->{_message} = join '; ' => map $_->message, @errors;
    # and return false
    return $self->{_message};
}

sub check ($self, $value) {
    # if &validate returns undef then
    # we passed successfully, so convert
    # this into a boolean
    return not defined $self->validate( $value );
}

sub has_coercion       { 0 }
sub can_be_inlined     { 0 }
sub inline_environment { +{} }

sub has_message       : predicate('_message');
sub get_message       ($self, @) { $self->{_message} }
sub _default_message  ($self, @) { $self->{_message} //= ($self->{type}->name . ' - Validation Error') }

sub _compiled_type_constraint ($self, @) {
    return $self->{_compiled} ||= sub { return $self->check( $_[0] ) };
}

1;

__END__
