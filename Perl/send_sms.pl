#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Readonly;
use Data::Dumper;
use WebService::Google::Voice::SendSMS;

Readonly my $GOOG_USER => 'themanchicken@gmail.com';
Readonly my $GOOG_PASS => 'MJr28821024$$gg06';

my ($pnum, $msg) = @ARGV;

if (!length $pnum || !length $msg) {
  die "I need a message and a number!";
}

my $goog = WebService::Google::Voice::SendSMS->new($GOOG_USER, $GOOG_PASS);

say "Got error: $@ / $!" if (!$goog->send_sms($pnum, $msg));

say 'Done.';