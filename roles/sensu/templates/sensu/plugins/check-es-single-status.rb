#!/usr/bin/env ruby
#
# Checks ElasticSearch single status
# ===
#
#
#
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class ESClusterStatus < Sensu::Plugin::Check::CLI

  option :host,
    :description => 'Elasticsearch host',
    :short => '-h HOST',
    :long => '--host HOST',
    :default => 'localhost'

  option :port,
    :description => 'Elasticsearch port',
    :short => '-p PORT',
    :long => '--port PORT',
    :proc => proc {|a| a.to_i },
    :default => 9200

  option :timeout,
    :description => 'Sets the connection timeout for REST client',
    :short => '-t SECS',
    :long => '--timeout SECS',
    :proc => proc {|a| a.to_i },
    :default => 30

  def get_es_resource(resource)
    begin
      r = RestClient::Resource.new("http://#{config[:host]}:#{config[:port]}/#{resource}", :timeout => config[:timeout])
      JSON.parse(r.get)
    rescue Errno::ECONNREFUSED
      critical 'Connection refused'
    rescue RestClient::RequestTimeout
      critical 'Connection timed out'
    rescue Errno::ECONNRESET
      critical 'Connection reset by peer'
    end
  end

  def get_status
    health = get_es_resource('/')
    health['status']
  end

  def run
    status = get_status
    case status
      when 200
        ok "OK #{status}"
      else
        critical "Unknown code #{status}"
    end
  end
end
