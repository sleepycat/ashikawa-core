require 'faraday'
require 'faraday_middleware'
require 'null_logger'
require 'ashikawa-core/minimal_logger'

module Ashikawa
  module Core
    # Create Faraday objects
    class FaradayFactory
      # Create a Faraday object
      #
      # @param [String] url The complete URL of the ArangoDB instance
      # @option options [Object] adapter The Faraday adapter you want to use. Defaults to Default Adapter
      # @option options [Object] logger The logger you want to use. Defaults to Null Logger.
      # @api private
      # @example Create a FaradayObject with the given configuration
      #  faraday = FaradayFactory.new('http://localhost:8529/_db/mydb/_api', logger: my_logger)
      def self.create_connection(url, options)
        debug_headers = options.fetch(:debug_headers) { false }
        logger  = options.fetch(:logger) { NullLogger.instance }
        adapter = options.fetch(:adapter) { Faraday.default_adapter }
        Faraday.new(url) do |connection|
          connection.request(:json)
          connection.response(:logger, logger)
          connection.response(:minimal_logger, logger, debug_headers: debug_headers)
          connection.response(:error_response)
          connection.response(:json)
          connection.adapter(*adapter)
        end
      end
    end
  end
end
