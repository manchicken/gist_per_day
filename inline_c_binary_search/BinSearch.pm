# /*
use strict;
use warnings;
use 5.010;

package BinSearch;

use Inline C => 'DATA' => (LIBS=>'m');
Inline->init;

require Exporter;
our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/do_binsearch/;

sub do_binsearch {
  my ($needle, @haystack) = @_;
  
  my @hcopy = sort (@haystack);
  
  my $found = _c_bin_search($needle, \@hcopy);
  
  return $found;
}

1; # */
__DATA__
__C__

#include <string.h>
#include <math.h>

// Remember, in Perl we don't care what the types are, but in C we do!
I32 compare(SV* a, SV* b) {
  if (!a || !b || !SvOK(a) || !SvOK(b)) {
    warn("An undefined value was passed to compare().");
    return -2;
  }
  
  if (SvNOK(a) && SvNOK(b)) {
    if (a < b) { return -1; }
    else if (b > a) { return 0; }
    return 0;
  }
  
  return sv_cmp(a, b);
}

// ASSUMES SORTED INPUT!
SV* _c_bin_search(SV* needle, AV* haystack) {
  I32 haystack_size = av_len(haystack) + 1;
  
  I32 look = 0;
  I32 left = 0;
  I32 right = 0;
  SV** item = NULL;
  
  // If the list has fewer than 1 element, return undef
  if (haystack_size <= 1) {
    item = av_fetch(haystack, 0, 0);
    
    // Usually an empty array
    if (item == NULL || !SvOK(*item)) {
      return &PL_sv_undef;
    }
    
    // See if the one item we have matches...
    if (compare(needle, *item) == 0) {
      return SvREFCNT_inc(*item);
    }
    
    return &PL_sv_undef;
  }
  
  left = 0;
  right = haystack_size;
  while (left < right) {
    // Pick where to look
    if (left+1 == right) { // This handles the race condition of only two items
      right = left;
    }
    look = (I32)ceil((left+right) / 2);
    
    // Get the item to consider
    item = av_fetch(haystack, look, 0);
    if (!SvOK(*item)) { warn("NOT VALID SV!"); return &PL_sv_undef; }

    // Deal with the outcome of the comparison
    switch (compare(needle,*item)) {
      case -1: // Look to the left
        right = look;
        break;
        
      case 1: // Look to the right
        left = look;
        break;
      
      default: // FOUND IT!
        return SvREFCNT_inc(*item);
    }
  }
  
  // If we're here we may have a situation where left == right, so let's look at it the one more time.
  item = av_fetch(haystack, left, 0);
  if (!SvOK(*item)) { warn("NOT VALID SV!"); return &PL_sv_undef; }
  if (compare(needle, *item) == 0) {
    
    return SvREFCNT_inc(*item);
  }
  
  return &PL_sv_undef;
}