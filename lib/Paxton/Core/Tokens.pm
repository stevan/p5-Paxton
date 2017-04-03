package Paxton::Core::Tokens;
# ABSTRACT: One stop for all your JSON needs

use strict;
use warnings;

use Scalar::Util ();

use Paxton::Core::Exception;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

## TODO:
# Put all these exports into properly
# segemented export groups, etc.
# For now we can just export everything
# by default, ugly, but fixable later.
# - SL

our ( @EXPORT, %TOKEN_MAP );
BEGIN {
    my $idx = 1;
    %TOKEN_MAP = (
        NOT_AVAILABLE  => Scalar::Util::dualvar( -1,     'NOT_AVAILABLE'  ),
        NO_TOKEN       => Scalar::Util::dualvar( 0,      'NO_TOKEN'       ),

        START_OBJECT   => Scalar::Util::dualvar( $idx++, 'START_OBJECT'   ),
        END_OBJECT     => Scalar::Util::dualvar( $idx++, 'END_OBJECT'     ),

        START_PROPERTY => Scalar::Util::dualvar( $idx++, 'START_PROPERTY' ),
        END_PROPERTY   => Scalar::Util::dualvar( $idx++, 'END_PROPERTY'   ),

        START_ARRAY    => Scalar::Util::dualvar( $idx++, 'START_ARRAY'    ),
        END_ARRAY      => Scalar::Util::dualvar( $idx++, 'END_ARRAY'      ),

        ADD_STRING     => Scalar::Util::dualvar( $idx++, 'ADD_STRING'     ),
        ADD_INT        => Scalar::Util::dualvar( $idx++, 'ADD_INT'        ),
        ADD_FLOAT      => Scalar::Util::dualvar( $idx++, 'ADD_FLOAT'      ),

        ADD_TRUE       => Scalar::Util::dualvar( $idx++, 'ADD_TRUE'       ),
        ADD_FALSE      => Scalar::Util::dualvar( $idx++, 'ADD_FALSE'      ),
        ADD_NULL       => Scalar::Util::dualvar( $idx++, 'ADD_NULL'       ),

        ERROR          => Scalar::Util::dualvar( $idx++, 'ERROR'          ),
    );

    @EXPORT = keys %TOKEN_MAP;

    foreach my $name ( keys %TOKEN_MAP ) {
        no strict 'refs';
        *{$name} = sub { $TOKEN_MAP{ $name } };
    }

    push @EXPORT => qw[
        is_boolean
        is_numeric
        is_error
        is_struct_start
        is_struct_end

        token
        is_token
    ];
}

sub import { (shift)->import_into( scalar caller, @_ ) }

sub import_into {
    my (undef, $into, @export) = @_;
    @export = @EXPORT unless @export;
    no strict 'refs';
    *{$into.'::'.$_} = \&{$_} foreach @export;
}

## token constructors

# NOTE:
# Think of tokens as an abstract data type that
# we don't really want to expose just yet.
# - SL

sub token {
    my ($type, $value) = @_;

    (exists $TOKEN_MAP{ $type })
        || Paxton::Core::Exception->new( message => 'Unknown token type (' . $type . ')' )->throw;

    return bless [ $type, $value ] => 'Paxton::Core::Tokens::Token';
}

sub Paxton::Core::Tokens::Token::type  { $_[0]->[0] }
sub Paxton::Core::Tokens::Token::value { $_[0]->[1] }

sub Paxton::Core::Tokens::Token::dump {
    require Data::Dumper;
    Data::Dumper::Dumper( $_[0] );
}

sub Paxton::Core::Tokens::Token::as_string {
    my $out  = 'token( '.$_[0]->type;

    if ( $_[0]->value ) {
        my $needs_quotes = $_[0]->type == ADD_STRING || $_[0]->type == START_PROPERTY;

        $out .= ', '
             .($needs_quotes ? '\'' : '')
             .$_[0]->value
             .($needs_quotes ? '\'' : '');
    }
    return $out.' )';
}

sub is_token {
    (Scalar::Util::blessed($_[0]) && $_[0]->isa('Paxton::Core::Tokens::Token'))
}

## useful predicates

sub is_boolean {
    ($_[0]->type == $TOKEN_MAP{ADD_TRUE} || $_[0]->type == $TOKEN_MAP{ADD_FALSE})
}

sub is_numeric {
    ($_[0]->type == $TOKEN_MAP{ADD_INT} || $_[0]->type == $TOKEN_MAP{ADD_FLOAT})
}

sub is_error {
    ($_[0]->type == $TOKEN_MAP{ERROR} || $_[0]->type == $TOKEN_MAP{NO_TOKEN} || $_[0]->type == $TOKEN_MAP{NOT_AVAILABLE})
}

sub is_struct_start {
    ($_[0]->type == $TOKEN_MAP{START_OBJECT} || $_[0]->type == $TOKEN_MAP{START_ARRAY})
}

sub is_struct_end {
    ($_[0]->type == $TOKEN_MAP{END_OBJECT} || $_[0]->type == $TOKEN_MAP{END_ARRAY})
}

1;

__END__

=pod

=head1 TOKENS

=head2 C<NOT_AVAILABLE>

=head2 C<NO_TOKEN>

=head2 C<START_OBJECT>

=head2 C<END_OBJECT>

=head2 C<START_PROPERTY>

=head2 C<END_PROPERTY>

=head2 C<START_ARRAY>

=head2 C<END_ARRAY>

=head2 C<ADD_STRING>

=head2 C<ADD_INT>

=head2 C<ADD_FLOAT>

=head2 C<ADD_TRUE>

=head2 C<ADD_FALSE>

=head2 C<ADD_NULL>

=head2 C<ERROR>

=cut
