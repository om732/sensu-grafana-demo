#!/usr/bin/env ruby
#
# README
#
# jolokia-heapmemory-check.rb
# ==================
# Check Heapmemory usage from jolokia.
#
# Description
# ------------
#
# Requirement
# ------------
# - sensu-plugin
# - rest-client
# - json
#
# Install
# ------------
#
# Usage
# ------------
# options
#   -u --url JOLOKIA URL (default: 127.0.0.1:8778)
#   -b --mbean MBEAN     (default: all)
#   -s --scheme SCHEME   (default: hostname)
#

require "rubygems"
require 'sensu-plugin/metric/cli'
require "rest-client"
require "json"

class JolokiaHeapmemoryCheck < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
    :short => '-u url',
    :long => '--url url',
    :description => 'Request URL',
    :default => "localhost:8778"

  option :warning,
    :description => "Metric naming scheme",
    :long => "--warning param",
    :default => 90

  option :critical,
    :description => "Metric naming scheme",
    :long => "--critical param",
    :default => 80

  def api_request(url)
    begin
      request = RestClient::Resource.new(url)
      JSON.parse(request.get, :symbolize_names => true)
    rescue RestClient::ResourceNotFound
      warning "Resource not found: #{url}"
    rescue Errno::ECONNREFUSED
      warning "Connection refused"
    rescue RestClient::RequestFailed
      warning "Request failed"
    rescue RestClient::RequestTimeout
      warning "Connection timed out"
    rescue RestClient::Unauthorized
      warning "Missing or incorrect Sensu API credentials"
    rescue JSON::ParserError
      warning "Joloki returned invalid JSON"
    end
  end

  def get_mbean_list()
    mbean_list = {
      'mbean'     => 'java.lang:type=Memory',
      'attribute' => 'HeapMemoryUsage'
    }
  end

  def run
    mbean = get_mbean_list

    data = api_request("http://#{config[:url]}/jolokia/read/#{mbean['mbean']}/#{mbean['attribute']}")

    heap_memory_usage = data[:value][:used]
    heap_memory_max   = data[:value][:max]
    used_percent = (heap_memory_usage.to_f / heap_memory_max.to_f * 100).round(1)

    if used_percent.to_f > config[:critical].to_f
      critical "Critical #{used_percent}% (#{heap_memory_usage} / #{heap_memory_max})"
    elsif used_percent.to_f > config[:warning].to_f
      warning "Warning #{used_percent}% (#{heap_memory_usage} / #{heap_memory_max})"
    else
      ok "OK #{used_percent}% (#{heap_memory_usage} / #{heap_memory_max})"
    end

  end
end
