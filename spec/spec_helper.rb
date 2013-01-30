ENV["RACK_ENV"] ||= "test"

require 'bundler/setup'

require 'rack-cachely' # and any other gems you need
require 'active_support/core_ext'
require 'vcr'

ENV["CACHELY_URL"] = "http://1234567890@www.cachelyapp.com"

Dir[File.expand_path(File.join("support", "**", "*.rb"), File.dirname(__FILE__))].each {|f| require f}

RSpec.configure do |config|

  config.before do
    Rack::Cachely.config = Rack::Cachely::Config.new
  end

end