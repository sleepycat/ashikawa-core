# -*- encoding : utf-8 -*-

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

      # Initialize a new graph instance
      #
      # @param [Database] database A reference to the database this graph belongs to
      # @param [Hash] raw_graph The parsed JSON response from the database representing the graph
      def initialize(database, raw_graph)
        @database = database
        @name     = raw_graph['name'] || raw_graph['_key']
      end
    end
  end
end
