require 'sinatra'
require 'json'
require 'time'

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 3005

SERVICE_NAME = ENV['SERVICE_NAME'] || 'service-ruby-05'
PLATFORM = ENV['PLATFORM'] || 'render'

$incoming_requests = 0
$processing_requests = 0
$lock = Mutex.new

before do
  $lock.synchronize { $incoming_requests += 1 }
end

after do
  $lock.synchronize { $processing_requests += 1 }
end

get '/' do
  'Hello from Microservice 05 (Ruby Sinatra)'
end

get '/ping' do
  content_type :json
  { status: 'ok', service: SERVICE_NAME }.to_json
end

get '/spike' do
  content_type :json
  duration = (params['duration'] || 10).to_i
  end_time = Time.now + duration
  while Time.now < end_time
    Math.sqrt(64 * 64 * 64 * 64)
  end
  { message: "CPU spiked for #{duration} seconds", service: SERVICE_NAME }.to_json
end

get '/metrics' do
  content_type :json
  inc, proc = 0, 0
  $lock.synchronize do
    inc = $incoming_requests
    proc = $processing_requests
  end
  queue = [0, inc - proc].max

  # CPU estimation via Process.times
  t = Process.times
  cpu_time = t.utime + t.stime
  cpu_pct = [(cpu_time * 10).round(2), 100.0].min

  {
    platform: PLATFORM,
    service: SERVICE_NAME,
    timestamp: Time.now.utc.iso8601,
    cpu_usage_percent: cpu_pct,
    incoming_requests: inc,
    processing_requests: proc,
    queue_length: queue,
    measurement_method: 'application_runtime',
    cpu_allocation: '1vCPU'
  }.to_json
end