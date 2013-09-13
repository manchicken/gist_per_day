#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use POSIX qw/ceil/;
use Test::More tests => 403;

sub bin_search {
  my ($needle, $haystack) = @_;
  
  my ($l, $r) = (0, (scalar @{$haystack} - 1));
  my $mid = 0;
  
  if ($l == $r) {
    if ($haystack->[0] == $needle) { return $haystack->[0]; }
    return;
  }
  
  while ($l < $r) {
    $mid = ceil(($r+$l) / 2);

    if ($haystack->[$mid] == $needle) { return $haystack->[$mid]; }
    elsif (($l + 1) == $r) { $r = $l; }
    elsif ($needle < $haystack->[$mid]) { $r = $mid; }
    else { $l = $mid; }
  }
  
  if ($haystack->[$l] == $needle) { return $haystack->[$l]; }
  
  return;
}

sub find_pair {
  my ($goal, $l1, $l2) = @_;
  
  # We should iterate over the smaller of the two arrays
  my ($iterate, $search) = (undef,undef);
  
  if (scalar @{$l1} > scalar @{$l2}) {
    $search = $l1;
    $iterate = $l2;
  } else {
    $search = $l2;
    $iterate = $l1;
  }
  
  for my $val (@{$iterate}) {
    my $lookup = $goal - $val;
    if (defined bin_search($lookup, $search)) { return ($val, $lookup); }
  }
  
  return;
}

sub make_list {
  my ($step, $quantity) = @_;
  
  return map { $_ * $step } 1 .. $quantity;
}

my @list1 = make_list(3, 500);
my @list2 = make_list(2, 600);

# Using a fresh binary search function, put it through some quick paces.
is(bin_search($list1[0], \@list1), $list1[0], 'Test bin_search() left-inclusive...');
is(bin_search($list1[2], \@list1), $list1[2], 'Test bin_search() right-inclusive...');
is(bin_search($list1[-1], \@list1), $list1[-1], 'Test bin_search() somewhere in the middle...');

srand(time());
for ( 1 .. 100 ) {
  my $n1 = $list1[rand(scalar @list1)];
  my $n2 = $list2[rand(scalar @list2)];
  my $goal = $n1 + $n2;
  my @pair = find_pair($goal, \@list1, \@list2);
  
  is(scalar @pair, 2, 'Verify we got two values back...');
  is($pair[0]+$pair[1], $goal, 'Verify the pair adds up to the goal...');
  is(bin_search($pair[0], \@list1), $pair[0], 'Verify the 0th item in the pair is contained in list 1...');
  is(bin_search($pair[1], \@list2), $pair[1], 'Verify the 1th item in the pair is contained in list 2...');
}