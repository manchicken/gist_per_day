#!/usr/bin/env perl
use strict; use warnings;

use Test::More tests => 6;

my @prices = qw/2 3 3 4 3 2 3 4 5 6 7 8 9 10 9 8 7 6 5 4 3 2 1/;

# Rules:
# 1. @prices' indices are seconds
# 2. @prices' values are dollars for a stock
# 3. The price is not permitted to rise more than $1 per minute
# 4. There may be duplicates
# 5. Find all instances of a given price in the list
sub get_price_count_in_step {
  my ($needle, @haystack) = @_;

  my $x = 0;
  my @secs = ();

  while ($x < scalar(@haystack)) {
    my $y = $haystack[$x];
    print "\$x == $x && \$y == $y\n";
    if ($y == $needle) {
      print "Pushing $y as it is equal to $needle\n";
      push(@secs, $x+1);
      $x += 1;
    } else {
      print "Skipping by ".abs($needle - $y)."\n";
      $x += abs($needle - $y)
    }
  }

  return @secs
}

use Data::Dumper;

my @_1 = get_price_count_in_step(2, @prices);
print Dumper(\@_1);
is(scalar(@_1), 3, 'Verify we got three hits for price $2...');
is($_1[0], 1, 'Verify price $2 at second 1...');
is($_1[1], 6, 'Verify price $2 at second 6...');
is($_1[2], 22, 'Verify price $2 at second 22...');

@_1 = get_price_count_in_step(10, @prices);
print Dumper(\@_1);
is(scalar(@_1), 1, 'Verify we got one hit for price $10...');
is($_1[0], 14, 'Verify price $10 at second 14...');
