# -*- encoding : utf-8 -*-

require 'ashikawa-core/vertex_collection'
require 'ashikawa-core/edge_collection'

module Ashikawa
  module Core
    # A certain graph in the database.
    #
    # @note All CRUD operations on related collections (edges and vertices) must be performed
    #       through their corresponding graph class. Not doing so will eventually lead to inconsistency
    #       and data corruption.
    class Graph
      extend Forwardable

      # Sending requests is delegated to the database
      def_delegator :@database, :send_request

      # The database the Graph belongs to
      #
      # @return [Database] The associated database
      # @api public
      # @example
      #   database = Ashikawa::Core::Database.new('http://localhost:8529')
      #   raw_graph = {
      #     'name' => 'example_1',
      #     'edgeDefinitions' => [],
      #     'orphanCollections' => []
      #   }
      #   graph = Ashikawa::Core::Graph.new(database, raw_collection)
      #   graph.database #=> #<Database: ...>
      attr_reader :database

      # The name of the database
      #
      # @return [String] The name of the graph
      # @api public
      # @example
      #   database = Ashikawa::Core::Database.new('http://localhost:8529')
      #   raw_graph = {
      #     'name' => 'example_1',
      #     'edgeDefinitions' => [],
      #     'orphanCollections' => []
      #   }
      #   graph = Ashikawa::Core::Graph.new(database, raw_collection)
      #   graph.name #=> 'example_1
      attr_reader :name

      # The revision of the Graph
      #
      # @return [String] The revision of the Graph
      # @api public
      attr_reader :revision

      # The edge definitions for this Graph
      #
      # @return [Hash] The edge definitons of this Graph as a simple data structure
      # @api public
      attr_reader :edge_definitions

      # Initialize a new graph instance
      #
      # @param [Database] database A reference to the database this graph belongs to
      # @param [Hash] raw_graph The parsed JSON response from the database representing the graph
      def initialize(database, raw_graph)
        @database = database
        parse_raw_graph(raw_graph)
      end

      # Gets a list of vertex collections
      #
      # Due to the fact we need to fetch each of the collections by hand this will just return an
      # enumerator which will lazily fetch the collections from the database.
      #
      # @return [Enumerator] An Enumerator referencing the vertex collections
      def vertex_collections
        Enumerator.new do |yielder|
          vertex_collection_names.each do |collection_name|
            yielder.yield vertex_collection(collection_name)
          end
        end
      end

      # Adds a vertex collection to this graph
      #
      # If the collection does not yet exist it will be created. If it already exists it will just be added
      # to the list of vertex collections.
      #
      # @param [String] collection_name The name of the vertex collection
      # @return [VertexCollection] The newly created collection
      def add_vertex_collection(collection_name)
        response = send_request("gharial/#@name/vertex", post: { collection: collection_name })
        parse_raw_graph(response['graph'])
        vertex_collection(collection_name)
      end

      # Fetches a vertex collection associated with graph from the database
      #
      # @param [String] collection_name The name of the collection
      # @return [VertexCollection] The fetched VertexCollection
      def vertex_collection(collection_name)
        raw_collection = send_request("collection/#{collection_name}")
        VertexCollection.new(database, raw_collection, self)
      end

      # Checks if a collection is present in the list of vertices
      #
      # @param [String] collection_name The name of the collection to query
      # @return [Boolean] True if the collection is present, false otherwise
      def has_vertex_collection?(collection_name)
        vertex_collection_names.any? { |name| name == collection_name }
      end

      # Gets a list of edge collections
      #
      # Due to the fact we need to fetch each of the collections by hand this will just return an
      # enumerator which will lazily fetch the collections from the database.
      #
      # @return [Enumerator] An Enumerator referencing the edge collections
      def edge_collections
        Enumerator.new do |yielder|
          @edge_collections.each do |collection_name|
            yielder.yield edge_collection(collection_name)
          end
        end
      end

      def edge_collection(collection_name)
      end

      private

      # Parses the raw graph structure as returned from the database
      #
      # @param [Hash] raw_graph The structure as returned from the database
      def parse_raw_graph(raw_graph)
        @name               = raw_graph['name'] || raw_graph['_key']
        @revision           = raw_graph['_rev']
        @edge_definitions   = raw_graph['edge_definitions']
        @orphan_collections = raw_graph['orphan_collections']
        @vertex_collections = extract_vertex_collections
        @edge_collections   = extract_edge_collections
      end

      # Extracts the names of all the vertex collections from the raw graph
      #
      # @return [Array] Names of all vertex collections
      def extract_vertex_collections
        @orphan_collections | @edge_definitions.map { |edge_def| edge_def.values_at('from', 'to') }.flatten
      end

      # Extracts the names of all the edge collections from the raw graph
      #
      # @return [Array] Names of all edge collections
      def extract_edge_collections
        @edge_definitions.map { |edge_def| edge_def['collection'] }
      end

      # The list of names of the vertex collections
      #
      # @return [Array] The list of names
      # @api private
      def vertex_collection_names
        @vertex_collections
      end
    end
  end
end
