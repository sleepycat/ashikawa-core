module Ashikawa
  module Core
    # A JavaScript Transaction on the database
    class Transaction
      # The collections the transaction writes to
      #
      # @return [Array<String>]
      # @api public
      # @example Get the collections that the transaction writes to
      #   transaction.write_collections # => ["collection_1"]
      attr_reader :write_collections

      # The collections the transaction reads from
      #
      # @return [Array<String>]
      # @api public
      # @example Get the collections that the transaction reads from
      #   transaction.read_collections # => ["collection_1"]
      attr_reader :read_collections

      # If set to true, the transaction will write all data to disk before returning
      #
      # @return [Boolean]
      # @api public
      # @example Check, if the transaction waits for sync
      #   transaction.wait_for_sync #=> false
      attr_reader :wait_for_sync

      # If set to true, the transaction will write all data to disk before returning
      #
      # @param [Boolean] wait_for_sync
      # @api public
      # @example Activate wait sync
      #   transaction.wait_for_sync = true
      attr_writer :wait_for_sync

      # An optional numeric value used to set a timeout for waiting on collection locks
      #
      # @return [Integer]
      # @api public
      # @example Check how long the lock timeout is
      #   transaction.lock_timeout # => 30
      attr_reader :lock_timeout

      # An optional numeric value used to set a timeout for waiting on collection locks
      #
      # @param [Integer] lock_timeout
      # @api public
      # @example Set the lock timeout to 30
      #   transaction.lock_timeout = 30
      attr_writer :lock_timeout

      # Initialize a Transaction
      #
      # @param [Database] database
      # @param [String] action An action written in JavaScript
      # @option options [Array<String>] :write The collections you want to write to
      # @option options [Array<String>] :read The collections you want to read from
      # @api public
      # @example Create a Transaction
      #   transaction = Ashikawa::Core::Transaction.new(database, "function () { return 5; }",
      #     :read => ["collection_1"]
      def initialize(database, action, options)
        @database = database
        @action = action
        @write_collections = options[:write]
        @read_collections = options[:read]
        @wait_for_sync = false
      end

      # Execute the transaction
      #
      # @param [Object] action_params The parameters for the defined action
      # @return Object The result of the transaction
      # @api public
      # @example Run a Transaction
      #   transaction.execute({ :a => 5 })
      def execute(action_params = nil)
        args = {
          :collections => {},
          :waitForSync => wait_for_sync,
          :action => @action
        }
        args[:collections][:write] = write_collections unless write_collections.nil?
        args[:collections][:read] = read_collections unless read_collections.nil?
        args[:params] = action_params unless action_params.nil?
        args[:lockTimeout] = lock_timeout unless lock_timeout.nil?
        @database.send_request("transaction", :post => args)["result"]
      end
    end
  end
end
