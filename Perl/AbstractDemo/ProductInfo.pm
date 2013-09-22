use 5.010;
use strict;
use warnings;

package ProductInfo;

sub new {
  my ($pkg, $opts) = @_;
  
  my $self = { %{$opts} };
  
  $self->{name} //= 'Untitled Product';
  $self->{price} //= 1_000_000; # one million dollars
  
  return bless $self, $pkg;
}

1;