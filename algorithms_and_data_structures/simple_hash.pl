#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use Readonly;
use Test::More;

{
  package HashPair;
  use Readonly;
  Readonly our $HHASH => 0;
  Readonly our $HKEY  => 1;
  Readonly our $HVAL  => 2;

  sub new {
    my ( $pkg, $key, $value ) = @_;

    my $self = [ undef, $key, $value ];

    bless $self, $pkg;
    return $self unless defined $key;

    $self->[$HHASH] = HashMap->hashval($key);

    return $self;
  }

  sub get_hash {
    my ($self) = @_;
    return $self->[$HHASH];
  }

  sub get_key {
    my ($self) = @_;
    return $self->[$HKEY];
  }

  sub get_value {
    my ($self) = @_;
    return $self->[$HVAL];
  }

  package HashMap;
  use POSIX qw/ceil/;

  use Readonly;
  Readonly our $ENTRIES_DEFAULT => 3;
  Readonly our $OIDX_ITEMS      => 0;
  Readonly our $OIDX_CAPACITY   => 1;
  Readonly our $OIDX_COUNT      => 2;
  Readonly our $OIDX_GROW_COUNT => 3;
  Readonly our $GROW_THRESHOLD  => 0.8;    # Grow when we hit 80% capacity!
  Readonly our $GROW_AMOUNT     => 1.2;    # Grow by 20% with each attempt
  Readonly our $IS_PAIR         => -1;
  Readonly our $IS_DUPS         => 1;
  Readonly our $IS_NONE         => 0;

  sub hashval {
    my ( $self, $value ) = @_;

    return unpack( '%32A*', $value );
  }

  sub new {
    my ($pkg) = @_;

    my $self = [ [ 0 .. $ENTRIES_DEFAULT ], $ENTRIES_DEFAULT, 0, 0, ];

    return bless $self, $pkg;
  }

  # This probably isn't super efficient
  sub _grow {
    my ($self) = @_;

    my $new_size = ceil( ( $self->[$OIDX_CAPACITY] + 1 ) * $GROW_AMOUNT );
    my $cur_entries = $self->[$OIDX_ITEMS];
    $self->[$OIDX_CAPACITY] = $new_size;
    $self->[$OIDX_ITEMS]    = [ 0 .. $new_size ];
    $self->[$OIDX_COUNT]    = 0;

    for my $entry ( @{$cur_entries} ) {
      next
        unless defined $entry
        and ref($entry);    # Skip if it's not defined or not a ref

  # If we have duplicates then this won't be a HashPair, it'll be an arrayref.
  # In that case, iterate through each of the dups and re-store it.
      if ( ref $entry eq 'ARRAY' ) {
        for my $keydup ( @{$entry} ) {
          $self->store_pair($keydup);
        }
      } else {
        $self->store_pair($entry);
      }
    }

    $self->[$OIDX_GROW_COUNT] += 1;

    return $self->[$OIDX_GROW_COUNT];
  }

  sub store {
    my ( $self, $key, $value ) = @_;

    return $self->store_pair( HashPair->new( $key, $value ) );
  }

  sub _what_is_it {
    my ( $self, $value ) = @_;

    return $IS_DUPS
      if (defined $value
      and ref $value eq 'ARRAY'
      and ref $value->[0] eq 'HashPair' );    # Array

    return $IS_PAIR if ( defined $value and ref $value eq 'HashPair' ); # Pair

    return $IS_NONE;
  }

  sub store_pair {
    my ( $self, $pair ) = @_;

    my $idx = $pair->get_hash % $self->[$OIDX_CAPACITY];

    my $existing = $self->[$OIDX_ITEMS]->[$idx];

    # We have an item at the index, and it's a single item
    if ( $self->_what_is_it($existing) == $IS_PAIR ) {

      # Same key, overwrite
      if ( $existing->get_key eq $pair->get_key ) {
        $existing->[$HashPair::HVAL] = $pair->get_value;

        # Different key, make a dup list
      } else {
        my $new_ary =
          [ sort { $a->get_key cmp $b->get_key } ( $existing, $pair ) ];
        $self->[$OIDX_ITEMS]->[$idx] = $new_ary;
        $self->[$OIDX_COUNT] += 1;
      }

      # We have an existing list of items
    } elsif ( $self->_what_is_it($existing) == $IS_DUPS ) {

      # Let's look in the list and see if we have an item
      my $found_one = 0;
      for my $e ( @{$existing} ) {
        if ( $e->get_key eq $pair->get_key ) {
          $e->[$HashPair::HVAL] = $pair->get_value;
          $found_one += 1;
          last;
        }
      }

      # We didn't find one, go ahead and add it to the pile.
      if ( $found_one == 0 ) {
        push @{$existing}, $pair;
        $self->[$OIDX_ITEMS]->[$idx] =
          [ sort { $a->get_key cmp $b->get_key } @{$existing} ];
        $self->[$OIDX_COUNT] += 1;
      }

      # We don't have any existing items at this index
    } else {
      $self->[$OIDX_ITEMS]->[$idx] = $pair;
      $self->[$OIDX_COUNT] += 1;
    }

    # If we're getting a bit too big, grow.
    my $fatness_limit = ( $self->[$OIDX_CAPACITY] * $GROW_THRESHOLD );
    if ( $self->[$OIDX_COUNT] > $fatness_limit ) {
      $self->_grow();
    }

    return $self->[$OIDX_COUNT];
  }

  ## If we start wanting to optimize, we could always put a condition here
  ## where we use a binary search if the list gets too big.
  sub fetch {
    my ( $self, $key ) = @_;

    my $idx = $self->hashval($key) % $self->[$OIDX_CAPACITY];

    my $existing = $self->[$OIDX_ITEMS]->[$idx];

    return if $self->_what_is_it($existing) == $IS_NONE;

    if ( $self->_what_is_it($existing) == $IS_DUPS ) {
      for my $one ( @{$existing} ) {
        if ( $one->get_key eq $key ) {
          return $one->get_value;
        }
      }
    } elsif ( $existing->get_key eq $key ) {
      return $existing->get_value;
    }

    return;
  }

  sub count {
    my ($self) = @_;
    return $self->[$OIDX_COUNT];
  }

  sub capacity {
    my ($self) = @_;
    return $self->[$OIDX_CAPACITY];
  }

  sub allkeys {
    my ($self) = @_;

    my @to_return = ();

    for my $entry ( @{ $self->[$OIDX_ITEMS] } ) {
      next if $self->_what_is_it($entry) == $IS_NONE;

      if ( $self->_what_is_it($entry) == $IS_DUPS ) {
        for my $subentry ( @{$entry} ) {
          push @to_return, $subentry->get_key;
        }
      } else {
        push @to_return, $entry->get_key;
      }
    }

    return @to_return;
  }
};

Readonly my $TEST_HASH_SIZE => 500;
plan tests => ( ( $TEST_HASH_SIZE * 8 ) + 1 );

# use Data::Dumper;

my $h1 = HashMap->new();
for my $n ( 0 .. $TEST_HASH_SIZE - 1 ) {
  my $x = 0;

  ## THIS IS THE ONLY NATIVE PERL HASH IN THE WHOLE PROGRAM
  my $foo = { one => 1, 2 => 'two', n => $n };

  ok(
    $x = $h1->store( "key$n", "value$n" ),
    "T1: Verify I can store value $n..."
  );
  is( $h1->fetch("key$n"), "value$n",
    "T2: Verify when I fetch $n, the value looks good..." );
  is( $h1->count, $n + 1,
    'T3: Verify we now have ' . ( $n + 1 ) . ' items in the hash map...' );
  is( $h1->store( "key$n", "value.2$n" ),
    $x, "T4: Verify we can store to update for $n..." )
    or diag explain $h1;
  is( $h1->fetch("key$n"), "value.2$n",
    "T5: Verify when I fetch $n, the value looks good..." );
  is( $h1->count, $n + 1,
    'T6: Verify we still have ' . ( $n + 1 ) . ' items in the hash map...' );

  is( $h1->store( "key$n", \$foo ),
    $x, 'T7: Verify we can store a reference...' );
  is( $h1->fetch("key$n"), \$foo, 'T8: Verify we got back a reference...' );
}

ok(
  $TEST_HASH_SIZE == scalar $h1->allkeys,
  "Verify we have $TEST_HASH_SIZE keys now..."
);
