# This package allows us to simulate the same interfaces of Android
# so that we can test our script before deploying it on our handset!
package Android;

use 5.010;
use strict;
use warnings;

sub new {
  my ($pkg) = @_;
  
  my $self = {};
  
  return bless $self, $pkg;
}

sub smsSend {
  my ($self, $dest, $msg) = @_;
  
  say "\aI want to send a message to $dest saying: $msg";
}

1;