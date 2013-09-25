use 5.010;
use strict;use warnings;

package UnloadTest;

sub BEGIN {
  $main::BEGUN = 1;
}

sub END {
  $main::ENDED = 1;
}

1;