require 'socket'

def parse_request(request_line)
  http_method, path_and_params, http = request_line.split
  path, params = path_and_params.split('?')

  params = params.split('&').each_with_object({}) do |pair, hash|
    key, value = pair.split('=')
    hash[key] = value
  end

  [http_method, path, params]
end

server = TCPServer.new('localhost', 3003)
loop do
  client = server.accept
  request_line = client.gets
  next if !request_line || request_line =~ /favicon/

  puts request_line
  # GET /?rolls=2&sides=6 HTTP/1.1
  http_method, path, params = parse_request(request_line)

  puts http_method
  puts path
  puts params

  rolls = params['rolls'].to_i
  sides = params['sides'].to_i

  rolls.times do
    roll = rand(sides) + 1
    puts roll
  end

  client.puts 'hello'
  client.close
end