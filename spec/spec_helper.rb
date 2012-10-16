require 'bundler/setup'

require 'rack-cachely' # and any other gems you need
require 'active_support/core_ext'
require 'vcr'

Dir[File.expand_path(File.join("support", "**", "*.rb"), File.dirname(__FILE__))].each {|f| require f}

RSpec.configure do |config|

  config.before do
    Rack::Cachely.config = Rack::Cachely::Config.new(cachely_api_key: '1234567890', cachely_url: "http://localhost:9292")
  end

end