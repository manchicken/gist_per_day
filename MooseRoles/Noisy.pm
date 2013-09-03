use strict;
use warnings;
use 5.010;
use feature 'say';

package Noisy;
use Moose::Role;

sub make_noise {
  my ($self) = @_;
  
  print 'The '.$self->name.' says: ';
}

1;