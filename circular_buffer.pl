#!/usr/bin/env perl
use strict;use warnings;

use Test::More;
use Readonly;

Readonly our $LIST_SIZE_LIMIT => 10_000;

{
  package Circle;

  sub new {
    my ($pkg, $size) = @_;

    if ($size > $LIST_SIZE_LIMIT) {
      die "Sorry, $LIST_SIZE_LIMIT is the limit of entries in the list.";
    }

    my $self = {
      elements => [],
      oldest => 0,
      youngest => 0,
      limit => $size,
    };
    $self->{elements}->[$size-1] = undef; # Grow the array

    return bless($self, $pkg);
  }

  sub youngest {
    my ($self) = @_;

    return $self->{youngest};
  }

  sub oldest {
    my ($self) = @_;

    return $self->{oldest};
  }

  sub append {
    my ($self, $entry) = @_;

    die("Cannot append non-Entry") unless ($entry->isa(q{Entry}));

    $entry->{epoch} = time();

    my $oldest = $self->{oldest};
    my $youngest = $self->{youngest};

    # Handle empties...
    if ($oldest == 0 && $youngest == $oldest && !defined($self->{elements}->[$oldest])) {
      $self->{elements}->[$oldest] = $entry;
      return;
    }

    # Increment otherwise
    $oldest = ($oldest >= $self->{limit}-1) ? 0 : $oldest + 1;
    my $is_overwrite = defined($self->{elements}->[$oldest]);
    $self->{elements}->[$oldest] = $entry;

    if ($is_overwrite) {
      $self->{youngest} = ($self->{youngest} >= $self->{limit}-1) ? 0 : $self->{youngest} + 1;
    }

    $self->{oldest} = $oldest;
  }

  sub remove {
    my ($self, $count) = @_;

    if ($count > $self->{limit}) {
      warn "Can't remove more than the limit of ".$self->{limit};
      return;
    }

    my $x = $self->youngest();
    while ($count > 0) {
      $self->{elements}->[$x] = undef;

      $x = ($x+1 >= $self->{limit}) ? 0 : $x + 1;
      $count -= 1;
    }

    $self->{youngest} = ($x >= $self->{limit}) ? 0 : $x;
  }

  sub entries {
    my ($self, $count) = @_;

    my $l = ($self->youngest() > $self->oldest()) ? $self->youngest() - $self->{limit} : $self->youngest();
    my $r = $self->oldest();

    # If you're curious how my slices are calculated, uncomment this.
    # print "Printing from L=$l to R=$r\n";

    # Yay, a slice!
    my @to_return = @{$self->{elements}}[$l .. $r];

    return @to_return;
  }

  package Entry;

  sub new {
    my ($pkg, $data) = @_;

    my $self = {
      epoch => undef, # You didn't say how the timestamp was to be formatted
      data => $data,
    };

    return bless($self, $pkg);
  }

  sub data {
    my ($self) = @_;

    return $self->{data};
  }
};

# AUTOMATED TESTS
plan tests => 62;
my $circle = Circle->new(5);
$circle->append(Entry->new("first"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'first', "Verify we have the data we expected...first");
is($circle->oldest(), 0, 'Verify oldest is 0...');
is($circle->youngest(), 0, 'Verify youngest is 0...');

$circle->append(Entry->new("second"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'second', "Verify we have the data we expected...second");
is($circle->oldest(), 1, 'Verify oldest is 1...');
is($circle->youngest(), 0, 'Verify youngest is 0...');

$circle->append(Entry->new("third"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'third', "Verify we have the data we expected...third");
is($circle->oldest(), 2, 'Verify oldest is 2...');
is($circle->youngest(), 0, 'Verify youngest is 0...');

$circle->append(Entry->new("fourth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'fourth', "Verify we have the data we expected...fourth");
is($circle->oldest(), 3, 'Verify oldest is 3...');
is($circle->youngest(), 0, 'Verify youngest is 0...');

$circle->append(Entry->new("fifth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'fifth', "Verify we have the data we expected...fifth");
is($circle->oldest(), 4, 'Verify oldest is 4...');
is($circle->youngest(), 0, 'Verify youngest is 0...');

$circle->append(Entry->new("sixth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'sixth', "Verify we have the data we expected...sixth");
is($circle->oldest(), 0, 'Verify oldest is 0...');
is($circle->youngest(), 1, 'Verify youngest is 1...');

$circle->append(Entry->new("seventh"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'seventh', "Verify we have the data we expected...seventh");
is($circle->oldest(), 1, 'Verify oldest is 1...');
is($circle->youngest(), 2, 'Verify youngest is 2...');

$circle->append(Entry->new("eighth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'eighth', "Verify we have the data we expected...eighth");
is($circle->oldest(), 2, 'Verify oldest is 2...');
is($circle->youngest(), 3, 'Verify youngest is 3...');

$circle->append(Entry->new("ninth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'ninth', "Verify we have the data we expected...ninth");
is($circle->oldest(), 3, 'Verify oldest is 3...');
is($circle->youngest(), 4, 'Verify youngest is 4...');

$circle->append(Entry->new("tenth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'tenth', "Verify we have the data we expected...tenth");
is($circle->oldest(), 4, 'Verify oldest is 4...');
is($circle->youngest(), 0, 'Verify youngest is 0...');

$circle->append(Entry->new("eleventh"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'eleventh', "Verify we have the data we expected...eleventh");
is($circle->oldest(), 0, 'Verify oldest is 0...');
is($circle->youngest(), 1, 'Verify youngest is 1...');

$circle->remove(2);
is($circle->oldest(), 0, 'Verify the oldest is now 1...');
is($circle->youngest(), 3, 'Verify the youngest is now 3...');
is($circle->{elements}->[2], undef, 'Verify we deleted index 2...');

$circle->append(Entry->new("twelfth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'twelfth', "Verify we have the data we expected...twelfth");
is($circle->oldest(), 1, 'Verify oldest is 1...');
is($circle->youngest(), 3, 'Verify youngest is 3...');

$circle->append(Entry->new("thirteenth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'thirteenth', "Verify we have the data we expected...thirteenth");
is($circle->oldest(), 2, 'Verify oldest is 2...');
is($circle->youngest(), 3, 'Verify youngest is 3...');

$circle->append(Entry->new("fourteenth"));
is(scalar(@{$circle->{elements}}), 5, 'Verify we still have five elements');
is($circle->{elements}->[$circle->{oldest}]->{data}, 'fourteenth', "Verify we have the data we expected...fourteenth");
is($circle->oldest(), 3, 'Verify oldest is 3...');
is($circle->youngest(), 4, 'Verify youngest is 4...');

my @entries = $circle->entries();
is(scalar(@entries), 5, 'Verify we got 5 entries...');
is($entries[0]->{data}, 'tenth', 'Verify that the 0th entry is "tenth"...');
is($entries[4]->{data}, 'fourteenth', 'Verify that the 0th entry is "fourteenth"...');
