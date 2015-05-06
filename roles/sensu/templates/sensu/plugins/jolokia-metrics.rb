#!/usr/bin/env ruby
#
# README
#
# jolokia-metrics.rb
# ==================
# Get JMX from jolokia.
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
#

require "rubygems"
require 'sensu-plugin/metric/cli'
require "rest-client"
require "json"
require "time"

class JolokiaMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
    :short => '-u url',
    :long => '--url url',
    :description => 'Request URL',
    :default => "localhost:8778"

  option :mbean,
    :short => '-m MBean',
    :long => "--mbean MBean",
    :description => "MBean name"

  option :scheme,
    :short => '-s SCHEME',
    :long => "--scheme SCHEME",
    :description => "Metric naming scheme",
    :default => "#{Socket.gethostname}.java"

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
      warning "Jolokia returned invalid JSON"
    end
  end

  def get_mbean_list()
    mbean_list = {
      'Heap' => {
        'mbean'     => 'java.lang:type=Memory',
        'attribute' => 'HeapMemoryUsage,NonHeapMemoryUsage'
      },
      'Metaspace' => {
        'mbean'     => 'java.lang:name=Metaspace,type=MemoryPool',
        'attribute' => 'Usage'
      },
      'Eden' => {
        'mbean'     => 'java.lang:name=Eden%20Space,type=MemoryPool',
        'attribute' => 'Usage'
      },
      'Survivor' => {
        'mbean'     => 'java.lang:name=Survivor%20Space,type=MemoryPool',
        'attribute' => 'Usage'
      },
      'CompressedClassSpace' => {
        'mbean'     => 'java.lang:name=Compressed%20Class%20Space,type=MemoryPool',
        'attribute' => 'Usage'
      },
      'TenuredGen' => {
        'mbean'     => 'java.lang:name=Tenured%20Gen,type=MemoryPool',
        'attribute' => 'Usage'
      },
      'ScavengeGC' => {
        'mbean'     => 'java.lang:name=Copy,type=GarbageCollector',
        'attribute' => 'CollectionCount,CollectionTime'
      },
      'FullGC' => {
        'mbean'     => 'java.lang:name=MarkSweepCompact,type=GarbageCollector',
        'attribute' => 'CollectionCount,CollectionTime'
      }
    }
  end

  def run
    result = {}
    mbean = get_mbean_list
    timestamp = (Time.now.to_i).to_s

    mbean.each do |k,v|
      data = api_request("http://#{config[:url]}/jolokia/read/#{v['mbean']}/#{v['attribute']}")
      result[k] = data[:value]
    end

    result.each do |name,param|
      param.each do |key,value|
        if value.instance_of?(Hash)
          value.each do |key_2,value_2|
            output "#{config[:scheme]}.#{key}.#{key_2}", value_2, timestamp
          end
        else
          output "#{config[:scheme]}.#{name}.#{key}", value, timestamp
        end
      end
    end
    ok
  end
end
