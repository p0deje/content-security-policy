$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'content-security-policy'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
