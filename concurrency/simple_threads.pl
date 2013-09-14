#!/usr/bin/env perl
use strict;use warnings;

use threads;

sub number_crunch {
  my ($sub, @set) = @_;
  
  my $product = 0;
  my $n = 0;
  
  while (my $x = shift(@set)) {
    $product = $sub->($product, ++$n, $x);
  }
  
  return $product;
}

my $avg = sub { my ($p,$n,$x) = @_; return (($p*($n-1))+$x)/$n; };
my $sum = sub { my ($p,$n,$x) = @_; return $p + $x; };

my @inset = (5,6,4,5,2,5,6,7,4,5);
my $t1 = threads->new(\&number_crunch, $avg, @inset);
my $t2 = threads->new(\&number_crunch, $sum, @inset);

my $avg_out = $t1->join();
my $sum_out = $t2->join();

print "I got an average of $avg_out and a sum of $sum_out. n == ".scalar(@inset)."\n";