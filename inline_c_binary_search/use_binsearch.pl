#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use feature 'say';

use BinSearch qw /do_binsearch/;

my @list = qw/horse chicken 123 abc 876 monkey 345 viper/;
my @empty = ();
my @one = ('chicken');
my @ints = qw/1 2 3 4 5 6 7 8 9/;

my $found = do_binsearch('chicken', @list) // 'undef';
say "I found $found.";

$found = do_binsearch('chicken', @one) // 'undef';
say "I found $found.";

$found = do_binsearch('chicken', @empty) // 'undef';
say "I found $found.";

$found = do_binsearch(1, @ints) // 'undef';
say "I found $found.";

$found = do_binsearch('chicken', @ints) // 'undef';
say "I found $found.";