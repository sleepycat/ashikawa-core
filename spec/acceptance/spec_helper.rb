# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ashikawa-core'
require 'logging'

PORT = ENV.fetch('ARANGODB_PORT', 8529)
USERNAME = ENV.fetch('ARANGODB_USERNAME', 'root')
PASSWORD = ENV.fetch('ARANGODB_PASSWORD', '')
AUTHENTIFICATION_ENABLED = ENV['ARANGODB_DISABLE_AUTHENTIFICATION'] == 'false'

def database_with_name(database_name = "_system")
  Ashikawa::Core::Database.new do |config|
    config.url    = "http://localhost:#{PORT}"
    # Log to a file
    logger = Logging.logger['ashikawa-logger']
    logger.add_appenders(
      Logging.appenders.file('log/acceptance.log')
    )
    logger.level = :debug

    config.logger        = logger
    config.database_name = database_name

    if AUTHENTIFICATION_ENABLED
      config.username = USERNAME
      config.password = PASSWORD
    end
  end
end

def database_with_random_name
  # This results in a database that has a valid name according to:
  # https://www.arangodb.org/manuals/2/NamingConventions.html#DatabaseNames
  database_with_name("a#{rand.to_s[2, 10]}")
end

# The database for the general specs
DATABASE        = database_with_name('ashikawa-acceptance-specs')
# Some specs require access to the _system database
SYSTEM_DATABASE = database_with_name('_system')

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    begin
      DATABASE.create
    rescue Ashikawa::Core::ClientError
    end
    DATABASE.truncate
  end
end
