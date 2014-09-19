# -*- encoding : utf-8 -*-

module Ashikawa
  module Core
    # Sets the ArangoDB API compatibility header
    class XArangoVersion < Faraday::Middleware
      # The name of the x-arango-version header field
      HEADER = 'X-Arango-Version'.freeze

      # Initializes the middleware
      #
      # @param [Callable] app The faraday app
      def initialize(app)
        super(app)
      end

      # Sets the `x-arango-version` for each request
      def call(env)
        env[:request_headers][HEADER] = Ashikawa::Core.api_compatibility_version
        @app.call(env)
      end
    end

    Faraday::Request.register_middleware x_arango_version: -> { XArangoVersion }
  end
end
