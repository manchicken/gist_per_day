#!/usr/bin/env perl
use strict;use warnings;

use Test::More tests => 5;
use Data::Dumper;

sub quicksort {
  my (@list) = @_;
  
  my $len = scalar(@list);
  
  # 1 or fewer elements in the list constitute a sorted list :)
  return @list unless ($len > 1);
  
  # Picking the middle as a pivot
  my $pivot_pos = int($len / 2);
  
  my $pivot_val = $list[$pivot_pos];
  
  my @greater = ();
  my @lesser = ();
  my @equal = ();
  
  my $lid = 0;
  for my $item (@list) {
    push(@lesser, $item) if ($item < $pivot_val);
    push(@equal, $item) if ($item == $pivot_val);
    push(@greater, $item) if ($item > $pivot_val);
  }
  
  return (quicksort(@lesser), @equal, quicksort(@greater));
}

my @list = qw{1 6 3 9 8 6 2 5 7};
my @output = quicksort(@list);

is(scalar(@list), scalar(@output), 'Verify we did not change the size of the lists...');
is($output[2], 3, 'Verify that item 2 is 3...');
is($output[-1], 9, 'Verify that the last item is a 9...');
is($output[4], 6, 'Verify that item 4 is a 6...');
is($list[-1], 7, 'Verify that the last item of the input was a 7...');
