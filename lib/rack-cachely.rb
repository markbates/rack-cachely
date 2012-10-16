require 'singleton'
require 'net/http'
require 'timeout'
require 'logger'
require 'fileutils'
require 'rack'
require "rack-cachely/version"
require "rack-cachely/config"
require "rack-cachely/context"
require "rack-cachely/store"
require "rack-cachely/key"

module Rack
  class Cachely

    def initialize(app, options = {})
      @app = app
      self.class.config = Rack::Cachely::Config.new(options)
    end

    def call(env)
      Context.new(@app).call(env)
    end

    class << self

      attr_accessor :config

    end

  end
end
