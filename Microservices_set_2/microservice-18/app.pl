#!/usr/bin/env perl

use Mojolicious::Lite;

get '/' => sub {
  my $c = shift;
  $c->render(text => 'Hello from Microservice 18 (Perl Mojolicious)');
};

app->start;