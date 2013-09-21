#!/usr/bin/env perl
use strict;
use warnings;

local $| = 1;

use lib qw/./;
use Android;

use JSON;
use HTTP::Tiny;

my $DEQUEUE_URL = 'http://manchicken.kd.io:80/androidsms.pl/dequeue';

my $android = Android->new();

my $info = HTTP::Tiny->new->get($DEQUEUE_URL);

if ($info->{content} eq 'EMPTY') {
  print "Nothing was in the queue.\n";
  exit 0;
}

my $obj = decode_json($info->{content});
$android->smsSend($obj->{to}, $obj->{message});
