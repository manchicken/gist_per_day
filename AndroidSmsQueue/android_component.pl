#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use JSON;
use HTTP::Tiny;
use Test::More;
use Readonly;

Readonly my $DEQUEUE_URL => 'http://manchicken.kd.io/androidsms.pl/dequeue';

# This package allows us to simulate the same interfaces of Android
# so that we can test our script before deploying it on our handset!
{
  package AndroidSubstitute;
  
  sub new {
    my ($pkg) = @_;
    
    my $self = {};
    
    return bless $self, $pkg;
  }
  
  sub smsSend {
    my ($self, $dest, $msg) = @_;
    
    say "\aI want to send a message to $dest saying: $msg";
  }
}

# We may want to run this on non-Android
my $android = eval('use Android;return Android->new();');
if ($@ || !defined $android) {
  $android = AndroidSubstitute->new();
}

ok($android->can('smsSend'), 'Verify that we can send an SMS...');

my $info = HTTP::Tiny->new->get($DEQUEUE_URL);
if ($info->{content} eq 'EMPTY') {
  say "Nothing was in the queue.";
  exit 0;
}

my $obj = decode_json($info->{content});
diag explain $obj;
$android->smsSend($obj->{to}, $obj->{message});