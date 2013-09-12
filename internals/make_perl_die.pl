#!/usr/bin/env perl
# Warning: This one's going to be a little violent.
# -------------------------------------------------
# I am talking about killing processes, and I fully
# intend to ham it up. This is all well-intentioned
# humor - possibly in bad taste. Plenty of actual
# processes died (and horribly so) in the making of
# this code sample.
#
# I do not repent...

use 5.010;
use strict;
use warnings;

use English;
use FindBin qw/$Bin/;
use POSIX qw/:sys_wait_h :signal_h/;

use Test::More tests => 41;

use Readonly;
Readonly my $LAMB_FOR_THE_SLAUGHTER => qq{$Bin/watch_perl_die.pl};

# This function prepares the lamb for the slaughter
sub prepare_lamb {
  my (@args) = @_;

  # Fork to create a child process...
  my $child_pid = fork();
  if ( $child_pid == 0 ) {
    exec $LAMB_FOR_THE_SLAUGHTER, @args
      ; # Exec to load the lamb process and execute it ONLY into the child process...
  }

  sleep(1);    # Sleep to let the child get ready

  return $child_pid;
}

# Send the signal to the child PID
sub slaughter_lamb {
  my ( $pid, $signal ) = @_;

  kill $signal, $pid;
  sleep(1);    # Sleep so that the signal handler can do its thing.
}

# This function returns a signal handler which then does a non-hanging wait for the child PID.
our $bloody = 0;

sub make_ready_the_reaper {
  my ( $lamb, $signame ) = @_;

  return sub {
    $bloody = 1;
    waitpid( $lamb, WNOHANG );
    
    my $retstat = $?;
    
    if (WIFEXITED($retstat)) {
      $retstat = WEXITSTATUS($retstat);
      say STDERR "TEST $signame: Exited with status $retstat";
    } elsif (WIFSIGNALED($retstat)) {
      $retstat = WTERMSIG($retstat);
      say STDERR "TEST $signame: Terminated with signal $retstat";
    } else {
      warn "TEST $signame: WTF?! $retstat is the exit code, but it's not coming up as a exit or a signal termination.";
    }
  };
}

# Run for these signals. Uncatchable signals should know to look for the absence of a head,
# not the presence of one.
my %tests = (
  q{INT}  => { sig => SIGINT,  catchable => 1 },
  q{USR1} => { sig => SIGUSR1, catchable => 1 },
  q{ALRM} => { sig => SIGALRM, catchable => 1 },
  q{TERM} => { sig => SIGTERM, catchable => 1 },
  q{SEGV} => { sig => SIGSEGV, catchable => 1 },
  q{STOP} => { sig => SIGSTOP, catchable => 0 },
  q{CONT} => { sig => SIGCONT, catchable => 1 },
  q{ABRT} => { sig => SIGABRT, catchable => 1 },
  q{PIPE} => { sig => SIGPIPE, catchable => 1 },
  q{CHLD} => { sig => SIGCHLD, catchable => 1 },
  q{KILL} => { sig => SIGKILL, catchable => 0 },
);

# Run tests!
for my $sig ( keys %tests ) {
  my $signum    = $tests{$sig}->{sig};
  my $catchable = $tests{$sig}->{catchable};

  # Make sure we didn't blow up before...
  ok( !$bloody && !( -e "$Bin/head.dat" ),
    'Verify that things are clean...' );

  # Spawn the child...
  my $lamb = prepare_lamb( $sig, "Caught $sig" );
  ok( $lamb > 0, 'Verify that the lamb is prepared for the slaughter...' );

  # This generates a signal handler and replaces SIGCHLD's handler with it
  local $SIG{CHLD} = make_ready_the_reaper( $lamb, $sig );

  # REDRUM <-- That's "MURDER" spelled backwards
  slaughter_lamb( $lamb, $signum );

  # Verify that SIGCHLD was trapped
  is( $bloody, 1, 'Verify that the reaper is bloody...' );
  $bloody = 0;    # Reset bloody bit

  # If the signal was catchable, verify we got a head on the floor
  # and clean it up for the next run.
  if ($catchable) {
    ok( ( -e "$Bin/head.dat" ), 'Verify that a head was dropped...' );
    unlink("$Bin/head.dat");
  } else {
    ok( !( -e "$Bin/head.dat" ), 'Verify that no head was dropped...' );
    unlink("$Bin/head.dat") if ( -e "$Bin/head.dat" );
  }

  # All done here!
  delete $tests{$sig};
}

is(scalar keys %tests, 0, 'Verify all tests were run...');