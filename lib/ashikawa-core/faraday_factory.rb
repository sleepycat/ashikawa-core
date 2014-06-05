require 'faraday'
require 'faraday_middleware'
require 'ashikawa-core/minimal_logger'

module Ashikawa
  module Core
    # Create Faraday objects
    class FaradayFactory
      # Create a Faraday object
      #
      # @param [String] url The complete URL of the ArangoDB instance
      # @option options [Object] adapter The Faraday adapter you want to use. Defaults to Default Adapter
      # @option options [Object] logger The logger you want to use. Defaults to no logger.
      # @api private
      # @example Create a FaradayObject with the given configuration
      #  faraday = FaradayFactory.new('http://localhost:8529/_db/mydb/_api', logger: my_logger)
      def self.create_connection(url, options)
        faraday = new
        faraday.debug_headers = options.fetch(:debug_headers) { false }
        faraday.logger = options.fetch(:logger) if options.has_key?(:logger)
        faraday.adapter = options.fetch(:adapter) { Faraday.default_adapter }
        faraday.faraday_for(url)
      end

      attr_accessor :debug_headers
      attr_accessor :request_middlewares
      attr_accessor :response_middlewares
      attr_accessor :adapter

      def initialize
        @request_middlewares = [:json]
        @response_middlewares = [:error_response, :json]
      end

      def logger=(logger)
        response_middlewares << [:minimal_logger, logger, debug_headers: debug_headers]
      end

      def faraday_for(url)
        Faraday.new(url) do |connection|
          request_middlewares.each { |middleware| connection.request(*middleware) }
          response_middlewares.each { |middleware| connection.response(*middleware) }
          connection.adapter(*adapter)
        end
      end
    end
  end
end
