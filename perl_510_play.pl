#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Test::More tests => 1;

# This is just a simple test script I'm using to play with Perl 5.10

sub test_state {
    my ($input) = @_;

    state $foo = undef;

    $foo = $input unless defined $foo;

    return $foo;
}

sub test_named_captures {
    my ($input) = @_;

    my $to_return = undef;

    if ( $input =~ m/^(?<foo>\d+?).*?$/ ) {
        $to_return = $+{foo};
    }

    return $to_return;
}

is( test_state(3), 3, 'Verify that test_state(3) returns 3...' );
is( test_state(5), 3,
    'Verify that the second call to test_state() returns 3 still...' );
is( test_named_captures('3FOO'),
    3, 'Verify that test_named_captures() returns 3...' );
is( test_named_captures('FOO3'),
    undef, 'Verify that test_named_captures() returns undef...' );
