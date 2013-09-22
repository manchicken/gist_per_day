use 5.010;
use strict;
use warnings;

package Chicken;

sub new {
  my ($pkg, %opts) = @_;

  my $self = { %opts };
  
  $self->{name} //= 'Chicken';
  
  return bless $self, $pkg;
}

sub respirate {
  my ($self) = @_;

  say "breathe in, breath out...";

  return;
}

sub fly {
  my ($self) = @_;

  say "flap flap fall...";

  return;
}

1;