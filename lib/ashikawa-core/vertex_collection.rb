# -*- encoding : utf-8 -*-

require 'ashikawa-core/collection'
require 'ashikawa-core/exceptions/client_error/resource_not_found/collection_not_in_graph'

module Ashikawa
  module Core
    # A vertex collection as it is returned from a graph
    #
    # @note This is basically just a regular collection with some additional attributes and methods to ease
    #       working with collections in the graph module.
    class VertexCollection < Collection
      # The Graph instance this VertexCollection was originally fetched from
      #
      # @return [Graph] The Graph instance the collection was fetched from
      # @api public
      attr_reader :graph

      # Create a new VertexCollection object
      #
      # @param [Database] database The database the connection belongs to
      # @param [Hash] raw_collection The raw collection returned from the server
      # @param [Graph] graph The graph from which this collection was fetched
      # @raise [CollectionNotInGraphException] If the collection has not beed added to the graph yet
      # @note You should not create instance manually but rather use Graph#add_vertex_collection
      # @api public
      def initialize(database, raw_collection, graph)
        super(database, raw_collection)
        @graph = graph

        raise CollectionNotInGraphException unless @graph.has_vertex_collection?(name)
      end
    end
  end
end
