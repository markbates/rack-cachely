module Rack
  class Cachely
    class Config

      attr_accessor :options

      def initialize(options = {})
        self.options = {ignore_query_params: [], allow_query_params: [], timeout: 1.0}
        options.each do |key, value|
          self.send("#{key}=", value)
        end
        self.options[:cachely_url] = "#{(self.options[:cachely_url] ||= ENV["CACHELY_URL"])}/v1/cache"
      end

      def ignore_query_params=(*args)
        self.options[:ignore_query_params] = [args].flatten.map {|x| x.downcase}
      end

      def allow_query_params=(*args)
        self.options[:allow_query_params] = [args].flatten.map {|x| x.downcase}
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
