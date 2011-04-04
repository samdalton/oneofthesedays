require 'rack/jekyll'

run Rack::Jekyll.new(:desination => "_site")
