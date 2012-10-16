module Rack
  class Cachely
    class Config

      attr_accessor :options

      def initialize(options = {})
        self.options = options
        self.options[:cachely_api_key] ||= ENV["CACHELY_API_KEY"]
        self.options[:cachely_url] = "#{(self.options[:cachely_url] ||= ENV["CACHELY_URL"])}/v1/cache?_token=#{self.options[:cachely_api_key]}"
      end

      def method_missing(sym, *args, &block)
        if /(.+)=$/.match(sym.to_s)
          self.options[$1.to_sym] = args[0]
        else
          self.options[sym]
        end
      end

      def logger
        self.options[:logger] ||= begin
          if Object.const_defined?(:Rails)
            logger = Rails.logger
          else
            path = ::File.expand_path("log", ::File.dirname(__FILE__))
            FileUtils.mkdir_p(path)
            logger = ::Logger.new(::File.join(path, "#{ENV['RACK_ENV']}.log"))
          end
          logger
        end
      end

    end
  end
end