#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use feature 'say';

use Animal;
use Chicken;

my $seal = Animal->new(name => "seal");
my $chicken = Chicken->new();

$seal->say_my_name;
$chicken->say_my_name;

for my $one ($seal, $chicken) {
  if ($one->does(q{Noisy})) {
    $one->make_noise();
  } else {
    say 'The '. $one->name . ' doesn\'t really say much.';
  }
}