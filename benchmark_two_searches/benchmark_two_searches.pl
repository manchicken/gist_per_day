#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use POSIX qw/ceil/;
use Benchmark qw/:all/;
use Readonly;

sub INIT {
  if (scalar(@ARGV) != 2) {
    die "Usage: $0 NUMTESTS SIZEOFLIST";
  }
}

Readonly my $TEST_LIMIT => $ARGV[0];
Readonly my $N_SIZE => $ARGV[1];

sub binsearch {
  my ($needle, $haystack, $is_sorted) = @_;
  
  my $sorted = (defined($is_sorted) && $is_sorted)? $haystack : [sort @{$haystack}];
  
  my $left = 0;
  my $right = scalar(@{$sorted});
  my $look = undef;
  
  if ($right <= 1) {
    return $sorted->[$right] if ($sorted->[$right] eq $needle);
    return undef;
  }
  
  while ($left < $right) {
    $right = $left if ($left + 1 == $right);
    $look = ceil(($left+$right)/2);
    
    my $c = ($sorted->[$look] cmp $needle);
    if ($c < 0) {
      $left = $look;
    } elsif ($c > 0) {
      $right = $look;
    } else {
      return $sorted->[$look];
    }
  }
  
  if ($sorted->[$left] eq $needle) {
    return $sorted->[$left];
  }
  
  return undef;
}

sub nsearch {
  my ($needle, $haystack) = @_;
  
  for my $x (0 .. (scalar(@{$haystack})-1)) {
    if ($haystack->[$x] eq $needle) {
      return $haystack->[$x];
    }
  }
  
  return undef;
}

srand(time());
my @list = ();

say 'Constructing list...';
for my $x (0...$N_SIZE) {
  push(@list, "abc$x");
}
say 'List is done...';

my $failcount = 0;

sub my_assert {
  my ($exp, $got) = @_;

  $failcount += 1 unless ($exp eq $got);
}

timethis($TEST_LIMIT, sub { my $foo = $list[rand(scalar(@list)-1)]; my_assert($foo, binsearch($foo, \@list, 0)); });
say "I had $failcount fails for binsearch() with unsorted input.";
$failcount = 0;
timethis($TEST_LIMIT, sub { my $foo = $list[rand(scalar(@list)-1)]; my_assert($foo, nsearch($foo, \@list))});
say "I had $failcount fails for nsearch().";
$failcount = 0;
@list = sort @list;
timethis($TEST_LIMIT, sub { my $foo = $list[rand(scalar(@list)-1)]; my_assert($foo, binsearch($foo, \@list, 1)); });
say "I had $failcount fails for binsearch() with *sorted* input.";
$failcount = 0;
