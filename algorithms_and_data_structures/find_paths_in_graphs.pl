#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More tests => 3;

sub newV {
  my ($name) = @_;

  return {name=>$name, visited=>0};
}

sub newE {
  my ($v1, $v2, $ordered) = @_;

  return {v1=>$v1, v2=>$v2, ordered=>($ordered//0)};
}

sub newG {
  return {V=>{}, E=>{}};
}

sub reset_visited_G {
  my ($g) = @_;

  for my $v (keys %{$g->{V}}) {
    $g->{V}->{$v}->{visited} = 0;
  }
}

sub add_Vs_to_G {
  my ($g, @v) = @_;

  for my $one (@v) {
    $g->{V}->{$one->{name}} = $one;
  }

  return $g;
}

sub add_Es_to_G {
  my ($g, @e) = @_;

  for my $one (@e) {
    $g->{E}->{$one->{v1}} //= [];
    push @{$g->{E}->{$one->{v1}}}, $one;
  }

  return $g;
}

# Find all adjacent vertices, exluding the ones we've seen (helps with cycles)
sub find_adjacent_unvisited {
  my ($g, $v, $seen) = @_;

  my @to_return = ();

  for my $one (@{$g->{E}->{$v}}) {
    if (exists $seen->{$one->{v2}}) { next; }
    push @to_return, $one->{v2};
  }

  return @to_return;
}

sub find_path {
  my ($g, $v1, $v2, $_path, $seen) = @_;

  $_path //= [];
  $seen //= {$v1=>$v1};

  if ($v1 eq $v2 && !scalar @{$_path}) { return ([$v1]); }

  my $path = [@{$_path}, $v1];

  my @results = ();

  my @adj = find_adjacent_unvisited($g, $v1, $seen);
  if (!scalar @adj) { return; }

  for my $a (@adj) {

    # We found a path, stick it into the results.
    if ($a eq $v2) {
      push @results, [@{$path}, $a];
    }

    # Let's go deeper and keep looking
    my @out = find_path($g, $a, $v2, $path, {%$seen,$a=>$a});
    if (scalar @out) {
      push @results, @out;
    }
  }

  return @results;
}

# Let's make our test graph...
my $g = newG();
add_Vs_to_G($g, newV('A'), newV('B'), newV('C'), newV('D'), newV('E'), newV('F'), newV('G'));
add_Es_to_G($g, newE(qw/A B/), newE(qw/A C/), newE(qw/A D/));
add_Es_to_G($g, newE(qw/B A/), newE(qw/B E/), newE(qw/B F/));
add_Es_to_G($g, newE(qw/C A/), newE(qw/C E/), newE(qw/C G/));
add_Es_to_G($g, newE(qw/D A/), newE(qw/D F/));
add_Es_to_G($g, newE(qw/E B/), newE(qw/E C/));
add_Es_to_G($g, newE(qw/F B/), newE(qw/F D/));
add_Es_to_G($g, newE(qw/G C/));

# Work on paths from F to C
my @pathsFC = find_path($g, qw/F C/);
for my $path (@pathsFC) { say 'Path: '.join ', ',@{$path}; }
is(scalar @pathsFC, 4, 'Verify we have four paths between F and C...');

# Paths from A to B
my @pathsAB = find_path($g, qw/A B/);
for my $path (@pathsAB) { say 'Path: '.join ', ',@{$path}; }
is(scalar @pathsAB, 3, 'Verify we have four paths between A and B...');

# See what happens for a
my @pathsAA = find_path($g, qw/A A/);
for my $path (@pathsAA) { say 'Path: '.join ', ',@{$path}; }
is(scalar @pathsAA, 1, 'Verify we have only the one path');