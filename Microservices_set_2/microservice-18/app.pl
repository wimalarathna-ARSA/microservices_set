#!/usr/bin/env perl

use Mojolicious::Lite -signatures;
use Time::HiRes ();

my %COUNTERS = (inc => 0, proc => 0, err => 0);
my $last_latency = 0;
my $start = time();

hook around_dispatch => sub ($next) {
  return sub ($c) {
    $COUNTERS{inc}++;
    my $t0 = Time::HiRes::time();
    my $res = $next->();
    $last_latency = (Time::HiRes::time() - $t0) * 1000;
    $COUNTERS{proc}++;
    if (($c->res->code // 200) >= 400) { $COUNTERS{err}++; }
    return $res;
  };
};

get '/' => sub ($c) {
  $c->render(text => 'Hello from Microservice 18 (Perl Mojolicious)');
};

get '/ping' => sub ($c) {
  $c->render(json => { status => 'ok', service => $ENV{SERVICE_NAME} // 'service-perl-18' });
};

get '/health' => sub ($c) {
  $c->render(json => {
    status => 'ok', service => $ENV{SERVICE_NAME} // 'service-perl-18',
    service_id => $ENV{SERVICE_NAME} // 'service-perl-18',
    platform => $ENV{PLATFORM} // 'render',
    target_reachable => \1, health_check_failed => 0,
    latency_ms => $last_latency, target => 'self'
  });
};

get '/metrics' => sub ($c) {
  my $inc = $COUNTERS{inc};
  my $proc = $COUNTERS{proc};
  my $err = $COUNTERS{err};
  $c->render(json => {
    platform => $ENV{PLATFORM} // 'render',
    service => $ENV{SERVICE_NAME} // 'service-perl-18',
    timestamp => scalar(gmtime),
    cpu_usage_percent => 0,
    incoming_requests => $inc, processing_requests => $proc,
    queue_length => ($inc > $proc ? $inc - $proc : 0),
    latency_ms => $last_latency,
    service_unreachable => 0, health_check_failed => 0, request_timeout => 0,
    http_errors_per_sec => $err,
    error_rate => ($inc > 0 ? $err / $inc : 0),
    uptime_seconds => time() - $start,
    measurement_method => 'application_runtime', cpu_allocation => 'unknown'
  });
};

get '/spike' => sub ($c) {
  my $d = $c->param('duration') // 10;
  my $end = time() + $d;
  while (time() < $end) { sqrt(64**5); }
  $c->render(json => { message => "CPU spiked for $d seconds", service => $ENV{SERVICE_NAME} // 'service-perl-18' });
};

$COUNTERS{err} = 0;

app->start;
