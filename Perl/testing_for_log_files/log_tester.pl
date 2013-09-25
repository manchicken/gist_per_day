#!/usr/bin/env perl
use 5.010;use strict;use warnings;

use Test::More tests => 5;

use DateTime;
use FindBin qw/$Bin/;
use IO::File;
use Fcntl qw/:DEFAULT/;

sub write_log_entry {
  my ($message, $level) = @_;
  
  $level = (defined $level) ? ucfirst(lc($level)) : 'Debug';
  
  # Make your log file based on the date as a (very) basic means of log rotation...
  my $logfile = sprintf('%s/mylog.%s.log', $Bin, DateTime->now()->strftime('%F'));
  say "Log file is: $logfile";
  my $timestamp = DateTime->now()->strftime('%F %T');
  
  # Use a state variable so you don't keep opening the file handle.
  state $log_fh = IO::File->new($logfile, O_CREAT|O_WRONLY|O_APPEND) or die "Cannot open file '$logfile' for writing: $!";
  
  $log_fh->print("(${timestamp}) ${level}: $message\n")
    or die "Failed to write line to log file '$logfile': $!";
  
  # This is here because when we want to test our code, this will help us.
  # Normally you wouldn't care about these values, but for the test they help get a better test.
  if (wantarray) {
    return ($logfile, $timestamp);
  }
  
  return 1;
}

# First let's write two entries into the log file. Note that we designed our code with the tests in mind!
my ($file1, $tstamp1) = write_log_entry('THIS IS A TEST!', 'info');
sleep 2; # In real life, the timestamps will differ...
my ($file2, $tstamp2) = write_log_entry('THIS IS A TEST!', 'BLAH');

# Make sure the log files are the same but the timestamps are not.
# ASSUMPTION: We're assuming that this test will start and finish within the same calendar day.
#             This seems like a safe assumption, but it should still be mentioned.
is $file1, $file2, 'Verify that we used the same file for both log writes...';
isnt $tstamp1, $tstamp2, 'Verify that the timestamps are different...';

# This open statement escapes to the shell and pipes the output of the command into a buffered stream.
open my $log_lines, "tail -n 2 '$file1' |"
  or die "Failed to get the last two lines from the log file: '$file1': $!";

# We're testing the first two lines here. Yes, I could be more clever, but I feel lazy.
my $line1 = <$log_lines>;
my $line2 = <$log_lines>;

# Since we got the timestamp from the function, we can do an exact comparrison.
is $line1, "($tstamp1) Info: THIS IS A TEST!\n", 'Verify line number 1 matches...';
is $line2, "($tstamp2) Blah: THIS IS A TEST!\n", 'Verify line number 2 matches...';

# We want to delete the file, and I'm only really testing it so you now if the file doesn't
# get deleted properly.
ok unlink($file1), 'Verify I can delete the file...';