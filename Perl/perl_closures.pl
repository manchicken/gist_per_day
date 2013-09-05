#!/usr/bin/env perl
use 5.010; # Perl 5.10 minimum!
use strict;use warnings;

sub make_closure {
  my @inputs = @_;
  
  return sub { join ',', @inputs, @_; };
}
my $_foo = make_closure(1,2,3,4);
say $_foo->('X');

{
  package DestroyDetector;
  sub new {
    my ($pkg, $val) = @_;
    my $self = {value=>$val};
    return bless $self, $pkg;
  }
  
  sub value {
    my ($self) = @_;
    return $self->{value};
  }
  
  sub announce {
    my ($self, $msg) = @_;
    $msg //= q{};
    say "Announcing DestroyDetector \"$msg\" value: ".$self->value;
  }
  
  sub DESTROY {
    my ($self) = @_;
    say "Destroying DestroyDetector value: ".$self->value;
    return;
  }
};

# First, let's prove that DestroyDetector announces when undef'ed.
my $foo1 = DestroyDetector->new('foo1');
$foo1->announce("about to undef foo1");
undef($foo1);

# Now, let's define a function which returns a closure...
sub closure_one {
  my ($value) = @_;
  
  my $detector = DestroyDetector->new($value);
  $detector->announce("Pre-closure definition...");
  
  return sub {
    my ($msg) = @_;
    
    $detector->announce($msg);
  };
}

# Now, let's get a copy of our closure...
my $closure1 = closure_one('closure1');
$closure1->('calling from the closure!');
$closure1->('About to undef() the closure...');
undef($closure1);
say 'You should have just seen the DestroyDetector destroy "closure1".';
