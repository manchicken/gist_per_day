#!/usr/bin/env perl
use strict;use warnings;

use Data::Dumper;

our $copies = 0;
our $compares = 0;

sub merge_sort {
  my ($compare, @input) = @_;

  if (scalar(@input) <= 1) {
    return @input;
  }

  my $mid = int(scalar(@input) / 2);

  # SPEED IDEA: Don't make deep copies

  my @left = merge_sort($compare, @input[0..$mid-1]);
  my @right = merge_sort($compare, @input[$mid..scalar(@input)-1]);


  return merge($compare, \@left, \@right);
}

sub merge {
  my ($compare, $left, $right) = @_;

  my @merged = ();

  my ($l, $r) = (0,0);

  # First run: try shifting off.
  # Speed-up ideas: iterate through the array rather than shifting
  while (scalar(@$left) > 0 && scalar(@$right) > 0) {
    if ($compare->($left->[0], $right->[0]) < 0) {
      $copies += 1;
      push(@merged, shift(@$left));
    } else {
      $copies += 1;
      push(@merged, shift(@$right));
    }
  }

  # Finished, add the rest of it to the merged list.
  push(@merged, @$left, @$right);

  return @merged;
}

my $compare = sub {
  my ($a, $b) = @_;

  $compares += 1;

  return $a cmp $b;
};

sub bubble_sort {
  my ($compare, @input) = @_;

  my ($x,$y) = (0,0);

  my @sorted = (@input);
  my $keep = undef;

  my $swapped = 0;
  do {
    $swapped = 0;
    for ($x = 0; $x < scalar(@input) - 1; $x += 1) {
      if ($compare->($input[$x], $input[$x+1]) < 0) {
        $swapped += 1;
        $copies += 1;
        $keep = $input[$x];
        $input[$x] = $input[$x+1];
        $input[$x+1] = $keep;
      }
    }
  } while ($swapped != 0);

  return @sorted;
}

my @in = split(m//, shift(@ARGV));

my @out = merge_sort($compare, @in);

print "Your input.... ".join("", @in)."\n";
print "Your output... ".join("", @out)."\n";
print "Only $compares comparisons and $copies copies, n = ".scalar(@in)."\n";

print "BUBBLE\n";
$compares = 0;
$copies = 0;
@out = bubble_sort($compare, @in);
print "Your input.... ".join("", @in)."\n";
print "Your output... ".join("", @out)."\n";
print "Only $compares comparisons and $copies copies, n = ".scalar(@in)."\n";
