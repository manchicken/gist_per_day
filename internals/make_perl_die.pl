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

use FindBin qw/$Bin/;
use POSIX qw/:sys_wait_h :signal_h/;
use Readonly;
Readonly my $LAMB_FOR_THE_SLAUGHTER => qq{$Bin/watch_perl_die.pl};

# This function prepares the lamb for the slaughter
sub prepare_lamb {
  my (@args) = @_;
  
  # Let's fork, exec and return the PID...
  my $child_pid = fork();
  if ($child_pid == 0) {
    exec $LAMB_FOR_THE_SLAUGHTER, @args;
  }
  
  sleep(2);
  
  return $child_pid;
}

sub slaughter_lamb {
  my ($pid, $signal) = @_;
  
  say "I'm going to try to kill $pid with $signal.";
  
  kill $signal, $pid;
}

sub make_ready_the_reaper {
  my ($output_msg) = @_;

  return sub {
    local($!,$?);
    my $pid = -1;
    
    while (($pid = waitpid(-1, WNOHANG)) > 0) {
      say $output_msg." for PID $pid, which exited with status $?.";
    }
  };
}

$SIG{CHLD} = make_ready_the_reaper('We always exit!');

my $lamb = prepare_lamb(q{INT}, 'Caught sigint!');
slaughter_lamb($lamb, SIGINT);
