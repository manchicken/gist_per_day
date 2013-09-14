#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use POSIX;
use FindBin qw/$Bin/;
use IO::File;

my ( $sig, $msg ) = @ARGV;

# This is our signal handler. We want to drop a head.dat file
# as a way of detecting that the child died.
sub death_throes {
  say STDERR "CHILD HERE: Caught signal '$sig': $msg";
  my $head = IO::File->new( "$Bin/head.dat", O_CREAT )
    || die 'Failed to drop a head! ' . $!;
  $head->print($$);
  exit(1);
}

# This program should always receive a signal, so this is just in case
my $suicide_counter = 0;

# Bind to our requested signal
local $SIG{$sig} = \&death_throes;

# Prove that we're bound to that signal
die "SIGNAL APPEARS UNBOUND!" unless ( $SIG{$sig} == \&death_throes );

# Wait for a signal (or suicide)
while ( 1 && $suicide_counter++ < 5 ) {
  sleep 5;
}

# Exit in the case of suicide.
exit(0);
