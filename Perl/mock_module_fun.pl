#!/usr/bin/env perl
use strict;
use warnings;
use 5.014;

use DateTime;
use Test::More tests => 12;
use Test::MockModule;

# Fancy new package block syntax
package SubjectOfTest {
  sub new {
    my ($pkg) = @_;
    
    my $self = {};
    
    return bless $self, $pkg;
  }
  
  sub advance_n_weeks_from_now {
    my ($self, $num_of_weeks) = @_;
    
    my $now = DateTime->now();
    
    return $now->add( weeks => $num_of_weeks );
  }
};

my $mocker = Test::MockModule->new(q{DateTime});
$mocker->mock('now', sub {
  return   my $dt = DateTime->new(
      year       => 2012,
      month      => 2,
      day        => 1,
      hour       => 12,
      minute     => 15,
      second     => 30,
      nanosecond => 0,
      time_zone  => 'America/New_York',
  );
});

my $mocked_now = DateTime->now();
is $mocked_now->year(), 2012, 'Verify the year...';
is $mocked_now->month(), 2, 'Verify the month...';
is $mocked_now->day(), 1, 'Verify the day of the month...';
is $mocked_now->hour(), 12, 'Verify the hour...';
is $mocked_now->minute(), 15, 'Verify the minute...';
is $mocked_now->second(), 30, 'Verify the second...';

# Now, let's try using our function...
my $tester = SubjectOfTest->new();
$mocked_now = $tester->advance_n_weeks_from_now(5);
is $mocked_now->year(), 2012, 'Verify the year...';
is $mocked_now->month(), 3, 'Verify the month...';
is $mocked_now->day(), 7, 'Verify the day of the month...';
is $mocked_now->hour(), 12, 'Verify the hour...';
is $mocked_now->minute(), 15, 'Verify the minute...';
is $mocked_now->second(), 30, 'Verify the second...';
