module Rack
  class Cachely
    class Context

      def initialize(app)
        @app = app
      end

      def request
        @request ||= Rack::Request.new(@env.dup.freeze)
      end

      def call(env)
        @env = env
        if self.perform_caching?
          results = Rack::Cachely::Store.get(key)
          if results
            return results
          end
        end
        results = @app.call(@env)
        if self.perform_caching? && is_cacheable?(results)
          Rack::Cachely::Store.post(key, results, age: @age.to_i)
        end
        return results
      end

      def perform_caching?
        config = if Kernel.const_defined?(:Rails)
          Rails.application.config.action_controller.perform_caching
        else
          @env['rack-cachely.perform_caching'].to_s == 'true'
        end
        config && request.request_method == 'GET'
      end

      def is_cacheable?(results)
        return false if results[0].to_i != 200
        headers = results[1]
        control = headers["Cache-Control"]
        if /public/.match(control) && /max-age=(\d+)/.match(control)
          @age = $1
          return true
        end
        return false
      end

      def key
        @key ||= Rack::Cachely::Key.new(request)
      end

      def config
        Rack::Cachely.config
      end

    end

  end
end