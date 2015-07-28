#!/usr/bin/env ruby
$stdout.sync = true

require 'em-eventsource'
require 'json'
require 'net/http'

ENV['EVENT_STREAM'] ||= 'Light_Sensor'
raise('needs environment variable TEMPO_HOST') unless ENV['TEMPO_HOST']
raise('needs environment variable TEMPO_USER') unless ENV['TEMPO_USER']
raise('needs environment variable TEMPO_PASS') unless ENV['TEMPO_PASS']
raise('needs environment variable PARTICLE_AUTH') unless ENV['PARTICLE_AUTH']

event_uri = URI("https://#{ENV['TEMPO_HOST']}/channels/0/event")

EM.run do
  source = EventMachine::EventSource.new('https://api.particle.io/v1/devices/events', {}, {'Authorization' => "Bearer #{ENV['PARTICLE_AUTH']}"} )
  source.on ENV['EVENT_STREAM'] do |message|
    message_hash = JSON.parse(message)
    message_time = message_hash.fetch('published_at')
    message_data = message_hash.fetch('data').to_i
    device_id = message_hash.fetch('coreid')
    return_hash = { '_$_ts' => message_time, ENV['EVENT_STREAM'] => message_data, 'device_id' => device_id }
    request_port = if event_uri.port
                     event_uri.port
                   else
                     if event_uri.scheme = 'https'
                       443
                     else
                       80
                     end
                   end

    puts "Request port: #{request_port}"

    Net::HTTP.start(event_uri.host, request_port, :use_ssl => event_uri.scheme == 'https' ) do |http|
      req = Net::HTTP::Post.new event_uri
      req.content_type = 'application/json'
      req.body = return_hash.to_json
      req.basic_auth ENV['TEMPO_USER'], ENV['TEMPO_PASS']
      puts req.body
      response = http.request req
      puts response.inspect
    end
  end
  puts "starting #{source.inspect}"
  source.start
end
