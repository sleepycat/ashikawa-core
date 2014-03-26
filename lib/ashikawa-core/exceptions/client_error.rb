# -*- encoding : utf-8 -*-
module Ashikawa
  module Core
    # The client had an error in the request
    class ClientError < RuntimeError
      # Create a new instance
      #
      # @param [Fixnum] status_code
      # @return RuntimeError
      # @api private
      def initialize(status_code)
        @status_code = status_code
      end

      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        @status_code
      end
    end
  end
end
