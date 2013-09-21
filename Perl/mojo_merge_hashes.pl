#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

use Mojolicious::Lite;

# Here's our validator construct
plugin 'validator' => {
  messages => {
    REGEXP_CONSTRAINT_FAILED => 'Invalid hash input',
    REQUIRED => 'Please supply both hash values.',
  },
};

get '/' => sub {
  my ($self) = @_;
  
  return $self->render('index');
};

post '/process' => sub {
  my ($self) = @_;
  
  my $re = qr/^(\w+:\w+,?)+$/xsm;
  
  my $v = $self->create_validator;
  $v->field('hash1')->required(1)->regexp($re);
  $v->field('hash2')->required(1)->regexp($re);
  
  $self->validate($v);
  
  my $hashes = { hash1 => {}, hash2 => {} };

  for my $hval (qw/hash1 hash2/) {
    my $h = $hashes->{$hval};
    
    for my $pair ( split m/,/, $self->param($hval) ) {
      my ($key, $val) = split m/:/, $pair, 2;
      
      $h->{$key} = $val;
    }
  }
  
  # Now the merge...
  # We want to loop over the largest one first, and then clean up on the second.
  my $first = undef;
  my $second = undef;
  if (keys %{$hashes->{hash1}} > keys %{$hashes->{hash2}}) {
    $first = $hashes->{hash1};
    $second = $hashes->{hash2};
  } else {
    $first = $hashes->{hash2};
    $second = $hashes->{hash1};
  }
  
  for my $key (keys %{$first}) {
    if (exists $second->{$key}) {
      # If we have two different values, make them into an array. Otherwise, just use the one from the first.
      if ($second->{$key} ne $first->{$key}) {
        $first->{$key} = [ $first->{$key}, $second->{$key} ];
      }
      delete $second->{$key};
    }
  }

  for my $key (keys %{$second}) {
    $first->{$key} = $second->{$key};
  }
  
  return $self->render('index', merged => $first);
};

app->start(q{cgi});

__DATA__

@@ index.html.ep
% layout 'main', title => 'Give me your hashes!';
% if (validator_has_errors) {
  <div class="error">Please, correct the errors below.</div>
% }
%= form_for 'process' => (enctype=>'multipart/form-data',method=>'post') => begin
  <h1>Hash 1</h1>
  <%= validator_error 'hash1' %>
  %= text_field 'hash1'
  <h1>Hash 2</h1>
  <%= validator_error 'hash2' %>
  %= text_field 'hash2'
  %= submit_button 'Do your thing'
% end
% if (defined stash 'merged') {
<pre>
%= dumper stash 'merged'
</pre>
% }

@@ layouts/main.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title><%= $title %></title>
    <!-- Credit to http://csslayoutgenerator.com/ for making the CSS nice and quick for me -->
    <style type="text/css">
      * {	margin: 0;	padding: 0.25em;}
      html {	height: 100%;}
      header, nav, section, article, aside, footer {	display: block;}
      body {	font: 12px/18px Arial, Tahoma, Verdana, sans-serif;	height: 100%;}
      a {	color: blue;	outline: none;	text-decoration: underline;}
      a:hover {	text-decoration: none;}
      p {	margin: 0 0 18px}
      img {	border: none;}
      input {	vertical-align: middle;}
      .error { color: darkred; font-weight: bold; }
      #wrapper {	min-width: 300px;	max-width: 1024px;	margin: 0 auto;	min-height: 100%;	height: auto !important;	height: 100%;}
      #header {	height: 150px;	background: #FFE680;}
      #content {	padding: 0 0 100px;}
      #footer {	margin: -100px auto 0;	min-width: 300px;	max-width: 1024px;	height: 100px;	background: #BFF08E;	position: relative;}
    </style>
  </head>
  <body>
    <%= content %>
  </body>
</html>