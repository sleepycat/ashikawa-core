# -*- encoding : utf-8 -*-
require 'ashikawa-core/exceptions/client_error.rb'

module Ashikawa
  module Core
    # This exception is thrown when the client used bad syntax in a request
    class BadSyntax < ClientError
      # Create a new instance
      #
      # @return RuntimeError
      # @api private
      def initialize message = 'Status 400: The syntax of the request was bad'
        @message = message
        super(400)
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        @message
      end
    end
  end
end
