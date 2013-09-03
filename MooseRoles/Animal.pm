use strict;
use warnings;
use 5.010;
use feature 'say';

package Animal;
use Moose;

has 'name' => (is=>'rw',isa=>'Str');

sub say_my_name {
  my ($self) = @_;
  say $self->name;
}

1;