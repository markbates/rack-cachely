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

        query = @request.query_string.split(/[&;] */n).map { |p| unescape(p).split('=', 2) }.sort
        query = query.reject{|k,v| Rack::Cachely.config.ignore_query_params.include?(k)}.map{ |k,v| "#{escape(k)}=#{escape(v)}" }

        query.join('&')
      end
    end

  end
end
