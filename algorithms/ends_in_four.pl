#!/usr/bin/env perl
use strict; use warnings;

if (scalar(@ARGV) != 1) {
  die "Usage: $0 INTEGER";
}

my $in = $ARGV[0];
if ($in !~ m/^-?[0-9]+$/) {
  die "Usage: $0 INTEGER (and it really must be an integer)";
}

if (($in % 10) == 4) {
  print "$in ends in 4!\n";
} else {
  print "$in doesn't end in 4!\n";
}

