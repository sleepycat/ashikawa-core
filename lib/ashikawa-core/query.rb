require 'ashikawa-core/cursor'
require 'ashikawa-core/document'
require 'ashikawa-core/exceptions/no_collection_provided'

module Ashikawa
  module Core
    # Formulate a Query on a collection or on a database
    class Query
      extend Forwardable

      # Delegate sending requests to the connection
      delegate send_request: :@connection

      # Initializes a Query
      #
      # @param [Collection, Database] connection
      # @return [Query]
      def initialize(connection)
        @connection = connection
      end

      # Retrieves all documents for a collection
      #
      # @note It is advised to NOT use this method due to possible HUGE data amounts requested
      # @option options [Integer] :limit limit the maximum number of queried and returned elements.
      # @option options [Integer] :skip skip the first <n> documents of the query.
      # @return [Cursor]
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @api public
      # @example Get an array with all documents
      #   query = Ashikawa::Core::Query.new collection
      #   query.all # => #<Cursor id=33>
      def all(options={})
        send_simple_query "/simple/all", options, [:limit, :skip]
      end

      # Looks for documents in a collection which match the given criteria
      #
      # @option example [Hash] a Hash with data matching the documents you are looking for.
      # @option options [Hash] a Hash with additional settings for the query.
      # @option options [Integer] :limit limit the maximum number of queried and returned elements.
      # @option options [Integer] :skip skip the first <n> documents of the query.
      # @return [Cursor]
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @api public
      # @example Find all documents in a collection that are red
      #   query = Ashikawa::Core::Query.new collection
      #   query.by_example { "color" => "red" }, :options => { :limit => 1 } # => #<Cursor id=2444>
      def by_example(example={}, options={})
        send_simple_query "/simple/by-example", { example: example }.merge(options), [:limit, :skip, :example]
      end

      # Looks for one document in a collection which matches the given criteria
      #
      # @param [Hash] example a Hash with data matching the document you are looking for.
      # @return [Document]
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @api public
      # @example Find one document in a collection that is red
      #   query = Ashikawa::Core::Query.new collection
      #   query.first_example { "color" => "red"} # => #<Document id=2444 color="red">
      def first_example(example = {})
        response = send_simple_query "/simple/first-example", { example: example }, [:example]
        response.first
      end

      # Looks for documents in a collection based on location
      #
      # @option options [Integer] :latitude Latitude location for your search.
      # @option options [Integer] :longitude Longitude location for your search.
      # @option options [Integer] :skip The documents to skip in the query.
      # @option options [Integer] :distance If given, the attribute key used to store the distance.
      # @option options [Integer] :limit The maximal amount of documents to return (default: 100).
      # @option options [Integer] :geo If given, the identifier of the geo-index to use.
      # @return [Cursor]
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @api public
      # @example Find all documents at Infinite Loop
      #   query = Ashikawa::Core::Query.new collection
      #   query.near latitude: 37.331693, longitude: -122.030468
      def near(options={})
        send_simple_query "/simple/near", options, [:latitude, :longitude, :distance, :skip, :limit, :geo]
      end

      # Looks for documents in a collection within a radius
      #
      # @option options [Integer] :latitude Latitude location for your search.
      # @option options [Integer] :longitude Longitude location for your search.
      # @option options [Integer] :radius Radius around the given location you want to search in.
      # @option options [Integer] :skip The documents to skip in the query.
      # @option options [Integer] :distance If given, the attribute key used to store the distance.
      # @option options [Integer] :limit The maximal amount of documents to return (default: 100).
      # @option options [Integer] :geo If given, the identifier of the geo-index to use.
      # @return [Cursor]
      # @api public
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @example Find all documents within a radius of 100 to Infinite Loop
      #   query = Ashikawa::Core::Query.new collection
      #   query.within latitude: 37.331693, longitude: -122.030468, radius: 100
      def within(options={})
        send_simple_query "/simple/within", options, [:latitude, :longitude, :radius, :distance, :skip, :limit, :geo]
      end

      # Looks for documents in a collection with an attribute between two values
      #
      # @option options [Integer] :attribute The attribute path to check.
      # @option options [Integer] :left The lower bound
      # @option options [Integer] :right The upper bound
      # @option options [Integer] :closed If true, use intervall including left and right, otherwise exclude right, but include left.
      # @option options [Integer] :skip The documents to skip in the query (optional).
      # @option options [Integer] :limit The maximal amount of documents to return (optional).
      # @return [Cursor]
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @api public
      # @example Find all documents within a radius of 100 to Infinite Loop
      #   query = Ashikawa::Core::Query.new collection
      #   query.within latitude: 37.331693, longitude: -122.030468, radius: 100
      def in_range(options={})
        send_simple_query "/simple/range", options, [:attribute, :left, :right, :closed, :limit, :skip]
      end

      # Send an AQL query to the database
      #
      # @param [String] query
      # @option options [Integer] :count Should the number of results be counted?
      # @option options [Integer] :batch_size Set the number of results returned at once
      # @return [Cursor]
      # @api public
      # @example Send an AQL query to the database
      #   query = Ashikawa::Core::Query.new collection
      #   query.execute "FOR u IN users LIMIT 2" # => #<Cursor id=33>
      def execute(query, options = {})
        options = allowed_options options, [:count, :batch_size]
        post_request "/cursor", options.merge({ query: query })
      end

      # Test if an AQL query is valid
      #
      # @param [String] query
      # @return [Boolean]
      # @api public
      # @example Validate an AQL query
      #   query = Ashikawa::Core::Query.new collection
      #   query.valid? "FOR u IN users LIMIT 2" # => true
      def valid?(query)
        begin
          !!post_request("/query", { query: query })
        rescue RestClient::BadRequest
          false
        end
      end

      private

      # The database object
      #
      # @return [Database]
      # @api private
      def database
        @connection.respond_to?(:database) ? @connection.database : @connection
      end

      # The collection object
      #
      # @return [collection]
      # @api private
      def collection
        raise NoCollectionProvidedException unless @connection.respond_to? :database
        @connection
      end

      # Send a simple query to the server
      #
      # @param [String] path The path for the request
      # @param [Hash] options The options given to the method
      # @param [Array<Symbol>] keys The required keys
      # @return [Hash] The parsed hash for the request
      # @raise [NoCollectionProvidedException] If you provided a database, no collection
      # @api private
      def send_simple_query(path, options, keys)
        options = allowed_options options, keys
        request_data = { collection: collection.name }.merge options
        put_request path, prepare_request_data(request_data)
      end

      # Removes the keys that are not allowed from an object
      #
      # @param [Hash] options
      # @param [Array<Symbol>] allowed_keys
      # @return [Hash] The filtered Hash
      # @api private
      def allowed_options(options, allowed_keys)
        options.keep_if { |key, _| allowed_keys.include? key }
      end

      # Transforms the keys into strings, camelizes them and removes pairs without a value
      #
      # @param [Hash] request_data
      # @return [Hash] Cleaned request data
      # @api private
      def prepare_request_data(request_data)
        Hash[request_data.map { |key, value|
          [key.to_s.gsub(/_(.)/) { $1.upcase }, value]
        }].reject { |_, value| value.nil? }
      end

      # Perform a put request
      #
      # @param [String] path
      # @param [Hash] request_data
      # @return [String] Server response
      # @api private
      def put_request(path, request_data)
        request_data = prepare_request_data request_data
        server_response = send_request path, :put => request_data
        Cursor.new database, server_response
      end

      # Perform a post request
      #
      # @param [String] path
      # @param [Hash] request_data
      # @return [Cursor]
      # @api private
      def post_request(path, request_data)
        request_data = prepare_request_data request_data
        server_response = send_request path, :post => request_data
        Cursor.new database, server_response
      end
    end
  end
end