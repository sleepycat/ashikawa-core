# -*- encoding : utf-8 -*-
require 'ashikawa-core/connection'

module Ashikawa
  module Core
    # Configuration of Ashikawa::Core
    class Configuration
      # The URL of the database instance
      # @api private
      # @return String
      attr_accessor :url

      # The Connection object
      # @api private
      # @return Connection
      attr_writer :connection

      # The logger instance
      # @api private
      # @return Object
      attr_accessor :logger

      # The HTTP adapter instance
      # @api private
      # @return Object
      attr_accessor :adapter

      # The username for authentication
      # @api private
      # @return String
      attr_accessor :username

      # The password for authentication
      # @api private
      # @return String
      attr_accessor :password

      # The name of the database you want to talk with
      # @api private
      # @return String
      attr_writer :database_name

      # The Connection object
      # @api private
      # @return Connection
      def connection
        @connection ||= setup_new_connection
        @connection.authenticate_with(username, password) if username && password
        @connection
      end

      # The name of the database you want to talk with
      # @api private
      # @return String
      def database_name
        @database_name ||= '_system'
      end

      private

      # Setup the connection object
      #
      # @param [String] url
      # @param [Logger] logger
      # @param [Adapter] adapter
      # @return [Connection]
      # @api private
      def setup_new_connection
        raise(ArgumentError, 'Please provide either an url or a connection to setup the database') if url.nil?

        Connection.new(url, database_name, connection_options)
      end

      def connection_options
        opts = {}
        opts[:logger] = logger if logger
        opts[:adapter] = adapter if adapter
        opts
      end
    end
  end
end
