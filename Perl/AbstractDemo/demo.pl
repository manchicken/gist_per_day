#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Test::More tests => 11;
use Test::Exception;

use lib q{.};

sub BEGIN {
  use_ok('Animal');
  use_ok('Module::Runtime', 'use_module');
}

sub load_by_eval {
  my ($class, @parms) = @_;

  # When using this method of loading, you really need to make sure that
  # you're verifying it's only got valid package characters...
  if ($class !~ m/^[a-z0-9:_-]+$/imsx) {
    die 'SECURITY EXCEPTION!';
  }

  eval("use $class");
  if ($@) {
    die "Cannot load $class: $@";
  }

  return $class->new(@parms);
}

# Test the eval method...
dies_ok { load_by_eval('while (fork()) { fork(); }') } 'Verify that the fork bomb dies...';
isa_ok(load_by_eval('Chicken'), 'Chicken', 'Verify that we loaded a Chicken by eval...');
isa_ok(load_by_eval('Seahorse'), 'Seahorse', 'Verify that we loaded a Seahorse by eval...');

# Let's test the re-bless method...
my $animal = Animal->new();
isa_ok($animal, 'Animal', 'Verify that we got an Animal...');
isa_ok($animal->morph_into('Chicken'), 'Chicken', 'Verify that we re-blessed into a Chicken...');
$animal = Animal->new();
isa_ok($animal, 'Animal', 'Verify that we got an Animal (again)...');
isa_ok($animal->morph_into('Seahorse'), 'Seahorse', 'Verify that we re-blessed into a Seahorse...');

# Now, final method, use Module::Runtime
isa_ok(use_module('Chicken')->new, 'Chicken', 'Verify we got a Chicken...');
isa_ok(use_module('Seahorse')->new, 'Seahorse', 'Verify we got a Seahorse...');