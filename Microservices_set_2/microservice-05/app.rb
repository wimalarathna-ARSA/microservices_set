require 'sinatra/base'
require 'json'
require 'time'
require 'etc'

class Microservice05 < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, ENV['PORT'] || 3005
  set :environment, ENV['RACK_ENV'] || 'production'
  set :show_exceptions, false
  set :raise_errors, false
  set :logging, true

  SERVICE_NAME = ENV['SERVICE_NAME'] || 'service-ruby-05'
  PLATFORM = ENV['PLATFORM'] || 'render'
  START_TIME = Time.now.utc

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
    'Hello from Microservice 05 (Ruby Sinatra) - Deployed on Render'
  end

  get '/health' do
    content_type :json
    {
      status: 'healthy',
      service: SERVICE_NAME,
      platform: PLATFORM,
      uptime: format_uptime(Time.now.utc - START_TIME),
      timestamp: Time.now.utc.iso8601
    }.to_json
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

    t = Process.times
    cpu_time = t.utime + t.stime
    cpu_pct = [(cpu_time * 10).round(2), 100.0].min

    memory_mb = nil
    begin
      status = File.read("/proc/#{Process.pid}/status")
      status.each_line do |line|
        if line.start_with?("VmRSS:")
          memory_mb = (line.split[1].to_i / 1024.0).round(2)
          break
        end
      end
    rescue Errno::ENOENT
      memory_mb = 0.0
    end

    cpu_count = Etc.nprocessors rescue 1

    {
      platform: PLATFORM,
      service: SERVICE_NAME,
      timestamp: Time.now.utc.iso8601,
      uptime: format_uptime(Time.now.utc - START_TIME),
      pid: Process.pid,
      ruby_version: RUBY_VERSION,
      cpu_usage_percent: cpu_pct,
      memory_usage_mb: memory_mb || 0.0,
      incoming_requests: inc,
      processing_requests: proc,
      queue_length: queue,
      measurement_method: 'application_runtime',
      cpu_allocation: "#{cpu_count}vCPU",
      threads: Thread.list.size
    }.to_json
  end

  private

  def self.format_uptime(seconds)
    days = (seconds / 86400).to_i
    hours = ((seconds % 86400) / 3600).to_i
    minutes = ((seconds % 3600) / 60).to_i
    secs = (seconds % 60).round(2)
    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0 || days > 0
    parts << "#{minutes}m" if minutes > 0 || hours > 0 || days > 0
    parts << "#{secs}s"
    parts.join(' ')
  end

  def format_uptime(seconds)
    self.class.format_uptime(seconds)
  end

  at_exit do
    Sinatra::Application.quit! if defined?(Sinatra::Application)
    puts "Microservice 05 shutting down gracefully..."
  end
end

Microservice05.run! if __FILE__ == $PROGRAM_NAME