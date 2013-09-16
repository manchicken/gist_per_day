#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More tests => 7;

sub count_bits {
  my ($num, $size) = @_;
  
  my $to_return = 0;
  
  for my $k (0 .. $size-1) {
    my $test = (1 << $k);
    if (0+$num & $test) { $to_return += 1; }
  }
  
  return $to_return;
}

# Yes, I'm assuming 32-bit integers
is(count_bits(2, 32), 1, 'Verify that 2 only has one bit...');
is(count_bits(5, 32), 2, 'Verify that 5 has two bits...');
is(count_bits(-1, 32), 32, 'Verify that -1 has 32 bits...');
is(count_bits(-2, 32), 31, 'Verify that -2 has 31 bits...');
is(count_bits(128, 32), 1, 'Verify that 128 has 1 bit...');
is(count_bits(12412, 32), 7, 'Verify that 12412 has 7 bits...');
is(count_bits(1+2+4+8+16+32+64+128+256+512+1024, 32), 11, 'Verify that the sum of bits 0 through 10 has eleven bits...');