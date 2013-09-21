#!/usr/bin/env perl
use strict;
use warnings;

local $| = 1;

## Yeah, don't do this. There's an issue in SL4A's Perl (or the API) which causes this to make the Android->new() hang.
# local $/ = undef;

use lib qw/./;
use Android;

use JSON;
use HTTP::Tiny;

my $android = Android->new;

my $DEQUEUE_URL = 'http://HOST_HERE/androidsms.pl/dequeue';

my $layout = q{};
while (my $_d = <DATA>) {
  $layout .= $_d;
}

sub process_queue {
  my $info = HTTP::Tiny->new->get($DEQUEUE_URL);

  if ($info->{content} eq 'EMPTY') {
    $android->ttsSpeak("Queue is empty.");
    return;
  }

  my $obj = decode_json($info->{content});
  $android->smsSend($obj->{to}, $obj->{message});
  $android->ttsSpeak("Sent Message: ".$obj->{message});
}

$android->fullShow($layout);

my $finished = 0;
while ($finished == 0) {
  my $e = $android->eventWaitFor('click');
  $android->eventClearBuffer();

  if ($e->{result}->{data}->{id} eq 'process') {
    process_queue();
  } elsif ($e->{result}->{data}->{id} eq 'exit_button') {
    $android->ttsSpeak("Fine then, I didn't like you anyway.");
    $finished = 1;
  } else {
    $android->ttsSpeak("Unknown event encountered. Good bye cruel world.");
    die " I DON'T KNOW WHAT YOU WANT FROM ME! ";
  }
}

$android->fullDismiss();
  
__DATA__
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    android:id="@+id/widget32"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#ff000000"
    xmlns:android="http://schemas.android.com/apk/res/android">
<TextView
    android:id="@+id/textView1"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Ready to Run Queue" />
<Button
    android:id="@+id/process"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Process Queue" />
<Button
    android:id="@+id/exit_button"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Exit the program!" />
</LinearLayout>
