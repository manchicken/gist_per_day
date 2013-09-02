use strict;use warnings;
require 5.010;use feature 'say';

package UseOrRequire;

sub INIT {
  say 'INIT CALLED!';
}

sub BEGIN {
  say 'BEGIN CALLED!';
}

sub END {
  say 'END CALLED!';
}

sub import {
  say 'import CALLED!';
}

sub say_hello {
  say 'hello! '.join(', ', @_);
}

1;