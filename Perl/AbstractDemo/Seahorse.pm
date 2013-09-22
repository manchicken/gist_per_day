use 5.010;
use strict;
use warnings;

package Seahorse;

sub new {
  my ($pkg, %opts) = @_;
  
  my $self = { %opts };
  
  $self->{name} //= 'Seahorse';
  
  return bless $self, $pkg;
}

sub respirate {
  my ($self) = @_;

  say "bubble bubble...";

  return;
}

sub swim {
  my ($self) = @_;

  say "bloop bloop...";

  return;
}

1;