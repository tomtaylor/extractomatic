require 'appengine-rack'
require 'extractomatic'

AppEngine::Rack.configure_app(
  :application => "extractomatic",
  :version => "1"
)

run Sinatra::Application