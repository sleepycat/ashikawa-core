$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'simplecov'
require 'coveralls'

unless defined?(Guard)
  # Do not run SimpleCov in Guard
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    command_name     'spec:unit'
    add_filter       'config'
    add_filter       'spec'
    minimum_coverage 99
  end
end

# Helper to simulate Server Responses. Parses the fixtures in the spec folder
require 'multi_json'
def server_response(path)
  return MultiJson.load(File.readlines("spec/fixtures/#{path}.json").join)
end

ARANGO_HOST = "http://localhost:8529"
