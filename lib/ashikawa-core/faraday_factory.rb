require 'faraday'
require 'faraday_middleware'
require 'ashikawa-core/minimal_logger'

module Ashikawa
  module Core
    # Create Faraday objects
    class FaradayFactory
      # Defaults for the options of create connection
      DEFAULTS = { additional_request_middlewares: [], additional_response_middlewares: [], adapter: Faraday.default_adapter }

      # Create a Faraday object
      #
      # @param [String] url The complete URL of the ArangoDB instance
      # @option options [Object] adapter The Faraday adapter you want to use. Defaults to Default Adapter
      # @option options [Object] logger The logger you want to use. Defaults to no logger.
      # @api private
      # @example Create a FaradayObject with the given configuration
      #  faraday = FaradayFactory.new('http://localhost:8529/_db/mydb/_api', logger: my_logger)
      def self.create_connection(url, options)
        options = DEFAULTS.merge(options)
        faraday = new(options.fetch(:additional_request_middlewares), options.fetch(:additional_response_middlewares))
        faraday.debug_headers = options.fetch(:debug_headers) { false }
        faraday.logger = options.fetch(:logger) if options.has_key?(:logger)
        faraday.adapter = options.fetch(:adapter)
        faraday.faraday_for(url)
      end

      # Debug headers to be used by Faraday
      #
      # @api private
      attr_accessor :debug_headers

      # Adapter to be used by Faraday
      #
      # @api private
      attr_writer :adapter

      # Create a new Faraday Factory with additional middlewares
      #
      # @param [Array] additional_request_middlewares Additional request middlewares
      # @param [Array] additional_response_middlewares Additional response middlewares
      # @api private
      def initialize(additional_request_middlewares, additional_response_middlewares)
        @request_middlewares = [:json] + additional_request_middlewares
        @response_middlewares = [:error_response, :json] + additional_response_middlewares
      end

      # Logger to be used by Faraday
      #
      # @param [Logger] logger The logger you want to use
      # @api private
      def logger=(logger)
        @response_middlewares << [:minimal_logger, logger, debug_headers: debug_headers]
      end

      # Create the Faraday for the given URL
      #
      # @param [String] url
      # @return [Faraday]
      # @api private
      def faraday_for(url)
        Faraday.new(url) do |connection|
          @request_middlewares.each { |middleware| connection.request(*middleware) }
          @response_middlewares.each { |middleware| connection.response(*middleware) }
          connection.adapter(*@adapter)
        end
      end
    end
  end
end
