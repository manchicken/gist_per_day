#!/usr/bin/env perl
use 5.010;use strict;use warnings;

our $BEGUN = 0;
our $ENDED = 0;

use Test::More tests => 4;

use UnloadTest;

is($BEGUN, 1, 'Verify BEGIN...');
is($ENDED, 0, 'Verify NOT ENDed...');

no UnloadTest;

is($BEGUN, 1, 'Verify BEGIN...');
is($ENDED, 1, 'Verify ENDed...');
