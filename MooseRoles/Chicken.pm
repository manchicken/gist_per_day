use strict;
use warnings;
use 5.010;
use feature 'say';

package Chicken;
use Moose;
extends 'Animal';
with 'Noisy';

has '+name' => (is=>'rw',isa=>'Str',default=>'chicken');

after 'make_noise' => sub {
  my ($self) = @_;
  
  say 'bok bok.';
};

1;