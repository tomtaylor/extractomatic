require 'appengine-rack'
require 'boilerpipe-live'

AppEngine::Rack.configure_app(          
  :application => "boilerpipe",           
  :version => "1"
)

run Sinatra::Application