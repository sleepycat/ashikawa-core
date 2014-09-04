# -*- encoding : utf-8 -*-
require 'ashikawa-core/exceptions/client_error/resource_not_found'

module Ashikawa
  module Core
    # This Exception is thrown when the collection was found in the database but was not
    # yet associated to the Graph.
    class CollectionNotInGraphException < ResourceNotFound
      # String representation of the exception
      #
      # @return String
      # @api private
      def to_s
        'The requested collection has not been added to the graph yet.'
      end
    end
  end
end
