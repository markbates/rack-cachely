module Rack
  class Cachely
    class Context

      def initialize(app)
        @app = app
      end

      def request
        @request ||= Rack::Request.new(@env.dup)
      end

      def call(env)
        @env = env
        if self.perform_caching?
          handle_refresh_request
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

      def handle_refresh_request
        if request.params["refresh-cachely"]
          Rack::Cachely::Store.delete(key)
        end
      end

      def perform_caching?
        perform_caching = if defined?(Rails)
          Rails.application.config.action_controller.perform_caching
        else
          @env['rack-cachely.perform_caching'].to_s == 'true'
        end
        perform_caching && config.enabled && request.request_method == 'GET' && !request.params["no-cachely"]
      end

      def is_cacheable?(results)
        status = results[0].to_i
        return false unless (200...300).include?(status)
        headers = results[1]
        control = headers["Cache-Control"]
        if /public/.match(control) && /max-age=(\d+)/.match(control)# && !/\/assets\//.match(key.to_s)
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
