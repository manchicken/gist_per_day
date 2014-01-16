#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use English;

for ( 1 .. 5 ) {
    next if ( fork() > 0 ); # Remember, fork returns zero to the child, and the PID of the child to the parent.
    
    identify_yourself(); # This sends the child process on its merry way.
}

while ( (my $reaped = wait()) > 0 ) {
    say "I just reaped PID $reaped.";
}

say 'I\'m all done here.';

sub identify_yourself {
    say "Hi! My name is $PID.";
    sleep 3; # Just to demonstrate my point.
    exit; # Remember, this is the child process exiting!
}