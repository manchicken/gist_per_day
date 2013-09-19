#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

# I know that Mojolicious also uses all of the super-fun use strict and use warnings,
# but I still feel irrationally compelled to put them in myself. I hereby offer my non-apology.
use Mojolicious::Lite;

use MongoDB;
use JSON;

use Readonly;

Readonly my $MONGO_DB => 'sl4a_mojo_demo';
Readonly my $MONGO_COLL => 'sms';

# Just get a handle to the Mongo collection we want.
sub get_mongo {
  my $client = MongoDB::MongoClient->new()
    or die 'Failed to get Mongo client: $!';
  my $db = $client->get_database( $MONGO_DB )
    or die 'Failed to get Mongo DB: $!';
  my $coll = $db->get_collection( $MONGO_COLL )
    or die 'Failed to get Mongo collection: $!';
  
  return $coll;
}

get '/' => sub {
  my ($self) = @_;
  
  return $self->render('form');
};

post '/sms' => sub {
  my ($self) = @_;
  
  my $to = $self->param('to_number')
    or return $self->redirect_to('/');
  my $msg = $self->param('sms_message')
    or return $self->redirect_to('/');

  eval {
    my $coll = get_mongo();
    $coll->insert({to=>$to,message=>$msg});
  }; if ($@) {
    return $self->render(text=>"Error: $@");
  }

  return $self->render('sent', to=>$to, msg=>$msg);
};

get '/dequeue' => sub {
  my ($self) = @_;

  my $record = undef;
  
  eval {
    my $coll = get_mongo();
    $record = $coll->find_and_modify({remove=>1});
  }; if ($@) {
    return $self->render(text=>"Error Fetching: $@");
  }
  
  if (!$record) {
    return $self->render(text=>'EMPTY');
  }

  my $json = JSON->new();
  $json->allow_blessed(1);
  
  return $self->render(text=>$json->encode($record));
};

app->start(q{cgi});

__DATA__

@@ form.html.ep
% layout 'main';
%= form_for 'sms' => (enctype=>'multipart/form-data',method=>'post') => begin
  <h1>Who to send to?</h1>
  %= text_field 'to_number'
  <h1>What would you like to send?</h1>
  %= text_field 'sms_message' => (maxlength=>140)
  %= submit_button 'Queue for Sending!'
% end

@@ sent.html.ep
% layout 'main';
<h1>Sent!</h1>
<h3>To: <%= $to %></h3>
<h3>Message</h3>
<p><%= $msg %></p>

@@ layouts/main.html.ep
<!DOCTYPE html>
<html>
  <head><title>Send a Message!</title></head>
  <body>
    <%= content %>
  </body>
</html>