#!/usr/bin/env perl
use strict;use warnings;

use Test::More;

sub quicksort {
  my ($list) = @_;
  
  my $len = scalar(@{$list});
  
  # 1 or fewer elements in the list constitute a sorted list :)
  return $list unless ($len > 1);
  
  # Picking the middle as a pivot
  my $pivot_pos = int($len / 2);
  my $hold = undef;
  
  my $pivot_val = $list->[$pivot_pos];
  
  my $righty = $len-1;
  my $lefty = 0;
  
  while ($lefty <= $righty) {
    $lefty += 1 while ($list->[$lefty] < $pivot_val);
    $righty -= 1 while ($list->[$righty] > $pivot_val);
    
    if ($list->[$lefty] <= $list->[$righty]) {
      $hold = $list->[$lefty];
      $list->[$lefty] = $list->[$righty];
      $list->[$righty] = $hold;
      undef $hold;
      $lefty += 1;
      $righty -= 1;
    }
  }
  quicksort(@{$list}[0..$pivot_pos-1]);
  quicksort(@{$list}[$pivot_pos..$len]);
  
  return $list;
}

my @list = qw{1 6 3 9 8 6 2 5 7};
quicksort(\@list);

use Data::Dumper;
print Dumper(\@list);




