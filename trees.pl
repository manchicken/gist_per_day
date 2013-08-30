#!/usr/bin/env perl
use strict;use warnings;

use Test::More tests => 22;
use Data::Dumper;

{
  package Node;

  sub compare {
    my ($self, $node) = @_;

    return $self->{key} cmp $node->{key};
  }

  sub new {
    my ($pkg, $key, $data) = @_;

    my $self = {
      key => (defined($key))?$key:undef,
      data => (defined($data))?$data:undef,
      height => 1,
      left => undef,
      right => undef,
    };

    return bless($self, $pkg);
  }

  sub add {
    my ($self, $node) = @_;

    my $ptr = undef;

    if ($self->compare($node) == 0) {
      return $self;
    }

    if ($self->compare($node) < 0) {
      if (defined($self->{right})) {
        $ptr = $self->{right}->add($node);
        $self->set_height();
        return $ptr;
      }

      $self->{right} = $node;
      $self->set_height();
      return $self->{right};
    } else {
      if (defined($self->{left})) {
        $ptr = $self->{left}->add($node);
        $self->set_height();
        return $ptr;
      }

      $self->{left} = $node;
      $self->set_height();
      return $self->{left};
    }
  }

  sub set_height {
    my ($self) = @_;

    my $rH = (defined($self->{right}))?$self->{right}->{height}:0;
    my $lH = (defined($self->{left}))?$self->{left}->{height}:0;

    $self->{height} = ($lH < $rH) ? $rH + 1 : $lH + 1;
  }

  sub balance {
    my ($self) = @_;

    if (!defined($self->{right}) && !defined($self->{left})) {
      return $self;
    }

    my $lH = (defined($self->{left}))?$self->{left}->{height}:0;
    my $rH = (defined($self->{right}))?$self->{right}->{height}:0;

    if ($lH + 1 < $rH) {
      print "Out of balance, rotate to the left.\n";
      return $self->rotate_left();
    } elsif ($lH > $rH + 1) {
      print "Out of balance, rotate to the right.\n";
      return $self->rotate_right();
    } else {
      print "Balanced!\n";
      $self->set_height();
      return $self;
    }
  }

  sub _move_right {
    my ($self) = @_;

    my $l = $self->{left};
    my $lr = $l->{right} || undef;

    $self->{left} = $lr;
    $l->{right} = $self;
    $self->set_height();
    $l->set_height();

    return $l;
  }

  sub _move_left {
    my ($self) = @_;

    my $r = $self->{right};
    my $rl = $r->{left} || undef;

    $self->{right} = $rl;
    $r->{left} = $self;
    $self->set_height();
    $r->set_height();

    return $r;
  }

  sub rotate_right {
    my ($self) = @_;

    my $l = (defined($self->{left}))?$self->{left}:undef;
    my $llH = (defined($l->{left}))?$l->{left}->{height}:0;
    my $lrH = (defined($l->{right}))?$l->{right}->{height}:0;

    if ($lrH > $llH) {
      $self->{left} = $l->_move_left();
    }

    return $self->_move_right();
  }

  sub rotate_left {
    my ($self) = @_;

    my $r = (defined($self->{right}))?$self->{right}:undef;
    my $rlH = (defined($r->{left}))?$r->{left}->{height}:0;
    my $rrH = (defined($r->{right}))?$r->{right}->{height}:0;

    if ($rlH > $rrH) {
      $self->{right} = $r->_move_right();
    }

    return $self->_move_left();
  }
}

my $d1 = Node->new('50', 'The number 50');
my $d2 = Node->new('60', 'The number 60');
my $d3 = Node->new('20', 'The number 20');
my $d4 = Node->new('30', 'The number 30');
my $d5 = Node->new('10', 'The number 10');
my $d6 = Node->new('05', 'The number 05');

is($d1->add($d2), $d2, 'Verify adding the item d2 to d1 tree...');
is($d1->add($d3), $d3, 'Verify adding the item d3 to d1 tree...');
is($d1->add($d4), $d4, 'Verify adding the item d4 to d1 tree...');
is($d1->add($d5), $d5, 'Verify adding the item d5 to d1 tree...');
is($d1->add($d6), $d6, 'Verify adding the item d6 to d1 tree...');

# print Dumper($d1);

# Prove we're out of balance
is($d1->{left}->{height}, 3, 'Verify that the left height is 3...');
is($d1->{right}->{height}, 1, 'Verify that the right height is 1...');

my $out = $d1->balance();
# print Dumper($out);
is($out->{left}->{height}, 2, 'Verify that, post balance, the left height is 2...');
is($out->{right}->{height}, 2, 'Verify that, post balance, the right height is 2...');
is($out->{right}->{left}->{key}, '30', 'Verify that we know the path to 30...');
is($out->{right}->{right}->{key}, '60', 'Verify that we know the path to 60...');

my $e1 = Node->new('10', 'The number 10');
my $e2 = Node->new('60', 'The number 60');
my $e3 = Node->new('20', 'The number 20');
my $e4 = Node->new('30', 'The number 30');
my $e5 = Node->new('50', 'The number 50');
my $e6 = Node->new('05', 'The number 05');
is($e1->add($e2), $e2, 'Verify adding the item e2 to e1 tree...');
is($e1->add($e3), $e3, 'Verify adding the item e3 to e1 tree...');
is($e1->add($e4), $e4, 'Verify adding the item e4 to e1 tree...');
is($e1->add($e5), $e5, 'Verify adding the item e5 to e1 tree...');
is($e1->add($e6), $e6, 'Verify adding the item e6 to e1 tree...');

# print Dumper($e1);
# Prove we're out of balance
is($e1->{left}->{height}, 1, 'Verify that the left height is 3...');
is($e1->{right}->{height}, 4, 'Verify that the right height is 1...');

my $out2 = $e1->balance();
# print Dumper($out2);
is($out2->{left}->{height}, 2, 'Verify that, post balance, the left height is 2...');
is($out2->{right}->{height}, 3, 'Verify that, post balance, the right height is 2...');
is($out2->{left}->{left}->{key}, '05', 'Verify that we know the path to 05...');
is($out2->{right}->{left}->{right}->{key}, '50', 'Verify that we know the path to 50...');
