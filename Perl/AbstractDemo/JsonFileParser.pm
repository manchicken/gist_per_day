use 5.010;
use strict;
use warnings;

package JsonFileParser;
use JSON;
use IO::File;
use Fcntl qw/:DEFAULT/;
use Try::Tiny;

sub new {
  my ($pkg, $opts) = @_;
  
  my $self = { %{$opts} };

  $self->{records} //= [];

  return bless $self, $pkg;
}

# Here's the method we know should be there
sub parse {
  my ($self, $data) = @_;
  
  my $json = decode_json($data);
  
  if (ref $json neq 'ARRAY') {
    die 'Input to parse() was not a JSON object with an array at the top-level.';
  }
  
  
}

1;