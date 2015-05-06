#!/opt/sensu/embedded/bin/ruby

require 'cgi'
require 'erb'

require 'net/http'
require 'uri'
require 'json'

$cgi = CGI.new

def render_json(json_list = [])
  print $cgi.header({"type" => "application/json", "charset" => "utf-8", "status" => "OK"})
  print JSON.generate(json_list)
  exit
end

def http_request(location, limit = 3)
  raise ArgumentError, 'too many HTTP redirects' if limit == 0
  uri = URI.parse(location)
  begin
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      location = response['location']
      warn "redirected to #{location}"
      http_request(location, limit - 1)
    else
      #puts [uri.to_s, response.value].join(" : ")
      return false
    end
  rescue => e
    #puts [uri.to_s, e.class, e].join(" : ")
    return false
  end
end

sensu_api_url = 'http://localhost:4567'
base_dir = File.expand_path(File.dirname($0))
template_dir = base_dir + "/template"
config_dir = base_dir + "/config"

append_clients_config_file = config_dir + '/append_clients.json'

templates = []
json_list = {}
clients = []
client_info = {}

param = {
  "name" => $cgi['name'],
  "item" => $cgi['item']
}

if param['name'].empty?
  render_json(json_list)
end



JSON.parse(http_request(sensu_api_url + '/clients/')).each{|v|
  client = {
    'name'    => v['name'],
    'address' => v['address'],
    'subscriptions' => v['subscriptions']
  }
  clients.push(client)

  if v['name'] == param['name'] then
    client_info = v
  end
}

if File.file?(append_clients_config_file) then
  JSON.parse(IO.read(append_clients_config_file)).each{|v|
    clients.push(v)
  }
end

clients = clients.sort_by{ |v| v['name'] }


param['item'].split(",").each{|v|
  unless client_info.key?(v) then
    client_info.store(v, {})
  end
  template_file_name = template_dir + "/" + v + ".erb"
  if File.file?(template_file_name) then
    erb = ERB.new(IO.read(template_file_name))
    templates.push(erb.result(binding))
  end
}
templates = "[" + templates.join(",") + "]"


json_list.store('clients', clients)
json_list.store('template', JSON.parse(templates))

json_list = Array[json_list]

render_json(json_list)
