#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

my ($sig,$msg) = @ARGV;

sub death_throes {
  say STDERR "Caught signal '$sig': $msg";
  exit(0);
}

my $suicide_counter = 0;

$SIG{$sig} = \&death_throes;

# First, let's try to bind
while (1) {
  exit 1 unless $suicide_counter++ < 5;
  print STDERR "Hi!\t";
  sleep 5;
}