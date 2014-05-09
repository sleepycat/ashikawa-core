# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'ashikawa-core'

PORT = ENV.fetch('ARANGODB_PORT', 8529)
USERNAME = ENV.fetch('ARANGODB_USERNAME', 'root')
PASSWORD = ENV.fetch('ARANGODB_PASSWORD', '')
AUTHENTIFICATION_ENABLED = ENV['ARANGODB_DISABLE_AUTHENTIFICATION'] == 'false'

# System Database for general use in specs
DATABASE = Ashikawa::Core::Database.new do |config|
  config.url = "http://localhost:#{PORT}"

  if AUTHENTIFICATION_ENABLED
    config.username = USERNAME
    config.password = PASSWORD
  end
end

def database_with_random_name
  # This results in a database that has a [valid name](https://www.arangodb.org/manuals/2/NamingConventions.html#DatabaseNames)
  name = "a#{rand.to_s[2,10]}"

  Ashikawa::Core::Database.new do |config|
    config.url = "http://localhost:#{PORT}/_db/#{name}"

    if AUTHENTIFICATION_ENABLED
      config.username = USERNAME
      config.password = PASSWORD
    end
  end
end
