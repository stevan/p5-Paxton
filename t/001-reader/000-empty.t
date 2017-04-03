#!perl

use strict;
use warnings;

use lib 't/lib/';

use Test::More;
use Test::Paxton;

tokens_match('',       [], '... simple empty input');
tokens_match('     ',  [], '... simple empty input w/ spaces');

done_testing;
