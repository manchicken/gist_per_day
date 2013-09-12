#!/usr/bin/env perl
use strict;use warnings;

use POSIX qw/ceil/;
use Test::More tests => 15;

sub find_last_name {
  my ($needle, @haystack) = @_;

  # ASSUMING SORTED!
  my $n = scalar(@haystack);
  my ($left,$right) = (0,$n-1);
  my $val = undef;

  # n = 0
  if ($n == 0) {
    return undef;

  # n = 1
  } elsif ($n == 1) {
    if ($needle eq $haystack[0]) {
      return $haystack[0]->[0];
    }
    return undef;
  }

  my $tries = 0;

  # n > 1
  while ($left < $right) {
    $tries += 1;
    my $spot = ceil(($left+$right) / 2); # Remember rounding!
    # print "Left:$left Right:$right Spot:$spot\n";

    $val = $haystack[$spot]->[0];
    my $_cmp = ($needle cmp $val);
    if ($_cmp == 0) {
      print "Found in $tries tries!\n";
      return $haystack[$spot]->[1];
    } elsif ($left+1 == $right) { # Address the inclusive search at the ends
      $right = $left;
    } elsif ($_cmp < 0) {
      $right = $spot;
    } elsif ($_cmp > 0) {
      $left = $spot;
    }
  }

  # You still need to check the left bound...
  if ($haystack[$left]->[0] eq $needle) {
    return $haystack[$left]->[1];
  }

  return undef;
}

my @names = (
  ["Alfred", "Hitchcock"],
  ["Brian", "Griffin"],
  ["Charlie", "Brown"],
  ["Doctor", "Dinosaur"],
  ["Edward", "Scissorhands"],
  ["Fred", "Flintstone"],
  ["George", "OfTheJungle"],
  ["Harvey", "Dent"],
  ["Iron", "Man"],
  ["Joe", "ThePlumber"],
  ["Kaptain", "Krunch"],
  ["Lex", "Luthor"],
  ["Max", "Payne"],
  ["Neil", "Tyson"],
);

my $x = 0;
for my $rec (@names) {
  is(find_last_name($rec->[0], @names), $rec->[1], 'Verify k = '.$x++.'...');
}
is(find_last_name('Undef', @names), undef, 'Verify not found...');
