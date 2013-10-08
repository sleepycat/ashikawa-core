# -*- encoding : utf-8 -*-
require 'ashikawa-core/exceptions/client_error.rb'

module Ashikawa
  module Core
    # This exception is thrown when the client is not authorized
    class AuthenticationFailed < ClientError
      # Create a new authentication failure
      #
      # @return RuntimeError
      # @api private
      def initialize
        super(401)
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        'Status 401: Authentication failed'
      end
    end
  end
end
