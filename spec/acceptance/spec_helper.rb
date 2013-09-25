# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

require "ashikawa-core"

ARANGO_HOST = "http://localhost:8529"

DATABASE = Ashikawa::Core::Database.new do |config|
  config.url = ARANGO_HOST
end
