module Rack
  class Cachely
    class Store
      include Singleton

      def self.method_missing(sym, *args, &block)
        self.instance.send(sym, *args, &block)
      end

      def get(key)
        remote do
          url = "#{config.cachely_url}?_version=#{Rack::Cachely::VERSION}&url=#{CGI.escape(key.to_s)}"
          if config.verbose
            logger.debug "Cachely [URL]: #{url}"
          end
          uri = URI(url)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)
          matches = url.scan(/\/\/(.+)@/).flatten

          if matches.any?
            u, p = matches.first.split(":")
            request.basic_auth(u, p)
          end
          response = http.request(request)
          if config.verbose
            logger.info "Cachely [uri]: #{uri}"
            logger.info "Cachely [response.code]: #{response.code}"
            logger.info "Cachely [response.body]: #{response.body}"
          end
          if (200...300).include?(response.code.to_i)
            headers = {}
            response.each_header do |key, value|
              headers[key] = value
            end
            return [response.code.to_i, headers, StringIO.new(response.body)]
          end
        end
        return nil
      end

      def post(key, rack, options = {})
        remote do
          body = rack[2].respond_to?(:body) ? rack[2].body : rack[2]
          data = {
            "document[url]" => key,
            "document[status]" => rack[0].to_i,
            "document[body]" => body,
            "document[age]" => options[:age] || 0,
            "_version" => Rack::Cachely::VERSION
          }
          rack[1].each do |key, value|
            data["document[headers][#{key}]"] = value
          end
          if config.verbose
            logger.debug "Cachely [data]: #{data.inspect}"
          end
          response = Net::HTTP.post_form(URI(config.cachely_url), data)
          if config.verbose
            logger.debug "Cachely [response.code]: #{response.code}"
            logger.debug "Cachely [response.body]: #{response.body}"
          end
        end
        return true
      end

      def delete(pattern)
        Net::HTTP.post_form(URI(config.cachely_url), {_method: "DELETE", pattern: pattern})
      end

      def remote(&block)
        begin
          Timeout::timeout(config.timeout, &block)
        rescue Timeout::Error, Errno::ECONNREFUSED => e
          # raise e
          logger.error(e)
        end
      end

      def config
        Rack::Cachely.config
      end

      def logger
        Rack::Cachely.config.logger
      end

    end
  end
end