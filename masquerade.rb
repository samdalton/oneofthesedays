require 'rubygems'
require 'sinatra'

set :public, Proc.new { File.join(root, "_site") }

# This before filter ensures that your pages are only ever served 
# once (per deploy) by Sinatra, and then by Varnish after that
before do
  response.headers['Cache-Control'] = 'public, max-age=31557600' # 1 year
end

get '/' do
    puts File.join(settings.public, 'index.html')
    send_file( File.join(settings.public, 'index.html') )
end

get '/favicon.ico' do
    # return favicon, eventually
end

get '/*' do
    send_file( File.join(settings.public, params[:splat], 'index.html') )
end


