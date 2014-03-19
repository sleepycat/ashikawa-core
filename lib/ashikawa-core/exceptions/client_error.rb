# -*- encoding : utf-8 -*-
module Ashikawa
  module Core
    # The client had an error in the request
    class ClientError < RuntimeError
      # Create a new instance
      #
      # @param [Integer] description
      # @return RuntimeError
      # @api private
      def initialize(description)
        @description = description
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        @description
      end
    end
  end
end
