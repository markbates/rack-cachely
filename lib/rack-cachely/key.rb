require 'rack/utils'

# Borrowed from Rache::Cache
module Rack
  class Cachely
    class Key
      include Rack::Utils

      def initialize(request)
        @request = request
      end

      # Generate a normalized cache key for the request.
      def generate
        @key ||= begin
          parts = []
          parts << @request.scheme << "://"
          parts << @request.host

          if @request.scheme == "https" && @request.port != 443 ||
              @request.scheme == "http" && @request.port != 80
            parts << ":" << @request.port.to_s
          end

          parts << @request.script_name
          parts << @request.path_info

          if query_string && query_string != ""
            parts << "?"
            parts << query_string
          end

          parts.join
        end
      end

      def to_s
        self.generate
      end

      private
      # Build a normalized query string by alphabetizing all keys/values
      # and applying consistent escaping.
      def query_string
        return nil if @request.query_string.nil?
        if whitelist_mode?
          whitelist(@request.query_string)
        else
          blacklist(@request.query_string)
        end
      end

      def whitelist(query_string)
        query_params = deparameterize(query_string)
        whitelisted_params = query_params.select{|k,v| whitelisted?(k) }
        parameterize(whitelisted_params)
      end

      def blacklist(query_string)
        query_params = deparameterize(query_string)
        blacklisted_params = query_params.reject{|k,v| blacklisted?(k) }
        parameterize(blacklisted_params)
      end

      def parameterize(params)
        params.map{ |k,v| "#{escape(k)}=#{escape(v)}" }.join('&')
      end

      def deparameterize(query_string)
        query_string.split(/[&;] */n).map { |p| unescape(p).split('=', 2) }.sort
      end

      def whitelisted?(param)
        Rack::Cachely.config.allow_query_params.include?(param)
      end

      def blacklisted?(param)
        ["no-cachely", "refresh-cachely", Rack::Cachely.config.ignore_query_params].flatten.include?(param)
      end

      def whitelist_mode?
        # Whitelist mode is enabled when the whitelist is the ONLY list set
        Rack::Cachely.config.ignore_query_params.empty? && Rack::Cachely.config.allow_query_params.any?
      end

      def blacklist_mode?
        !whitelist_mode?
      end
    end

  end
end
