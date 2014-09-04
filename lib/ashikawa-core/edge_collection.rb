# -*- encoding : utf-8 -*-
require 'ashikawa-core/collection'

module Ashikawa
  module Core
    # An edge collection as it is returned from a graph
    #
    # @note This is basically just a regular collection with some additional attributes and methods to ease
    #       working with collections in the graph module.
    class EdgeCollection < Collection
      # The Graph instance this EdgeCollection was originally fetched from
      #
      # @return [Graph] The Graph instance the collection was fetched from
      # @api public
      attr_reader :graph

      # Create a new EdgeCollection object
      #
      # @param [Database] database The database the connection belongs to
      # @param [Hash] raw_collection The raw collection returned from the server
      # @param [Graph] graph The graph from which this collection was fetched
      # @note You should not create instance manually but rather use Graph#add_edge_definition
      # @api public
      def initialize(database, raw_collection, graph)
        super(database, raw_collection)
        @graph = graph
      end
    end
  end
end
