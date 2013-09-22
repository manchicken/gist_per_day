use 5.010;
use strict;
use warnings;

package Animal;
use Seahorse;
use Chicken;

sub new {
  my ($pkg, %opts) = @_;
  
  my $self = { %opts };
  
  $self->{name} //= 'Dunno';
  
  return bless $self, $pkg;
}

sub morph_into {
  my ($self, $which) = @_;

  if ($which ne 'Chicken' && $which ne 'Seahorse') {
    die "Cannot morph into '$which'.";
  }

  return bless $self, $which;
}

1;