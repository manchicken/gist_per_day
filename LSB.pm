# Copyright (c) 2013,  Michael D. Stemle, Jr.
# This module may be distributed under the same terms as Perl itself.

package LSB;

our $VERSION = "1.0.0";

use Fcntl qw/:DEFAULT/;
use IO::File;
use Readonly;
use Carp qw/croak/;

Readonly our $ETC_LSB_RELEASE => '/etc/lsb-release';

sub new {
  my ($pkg, $file) = @_;
  
  my $self = {
    distrib_id => undef,
    distrib_release => undef,
    distrib_codename => undef,
    distrib_description => undef,
    _parsed => 0,
    _file => undef,
  };
  
  $self->{_file} = (defined($file) && length($file) > 0) ? $file : $ETC_LSB_RELEASE;
  
  bless $self, $pkg;
  
  $self->_parse;
  
  return $self;
}

sub _parse {
  my ($self) = @_;
  
  return if ($self->{_parsed} > 0);
  
  my $infile = IO::File->new($self->{_file}, O_RDONLY) ||
    croak 'Failed to open file "'.$self->{_file}.'" for reading: '.$!;
    
  while (my $line = $infile->getline) {
    next if ($line =~ m/^\s*#/); # Comments?
    chomp $line;
    my ($key,$val) = split m/=/, $line;
    
    $val =~ s/^\s*\"?(.*?)\"?\s*$/$1/smxe;
    if (exists $self->{lc $key}) {
      $self->{lc $key} = $val;
    }
  }
  
  $infile->close();
  
  return;
}

sub distrib_id { return $_[0]->{distrib_id}; }
sub distrib_release { return $_[0]->{distrib_release}; }
sub distrib_codename { return $_[0]->{distrib_codename}; }
sub distrib_description { return $_[0]->{distrib_description}; }

1;
