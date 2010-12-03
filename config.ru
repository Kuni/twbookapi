#run lambda {Rack::Response.new('Hello').finish}

require 'app'
run Sinatra::Application