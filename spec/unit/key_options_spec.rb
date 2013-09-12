require 'unit/spec_helper'
require 'ashikawa-core/key_options'

describe Ashikawa::Core::KeyOptions do
  subject { Ashikawa::Core::KeyOptions }

  it "should parse the key options" do
    type = double
    offset = double
    increment = double
    allow_user_keys = double

    key_options = subject.new({
      "type" => type,
      "offset" => offset,
      "increment" => increment,
      "allowUserKeys" => allow_user_keys
    })

    expect(key_options.type).to eq(type)
    expect(key_options.offset).to eq(offset)
    expect(key_options.increment).to eq(increment)
    expect(key_options.allow_user_keys).to eq(allow_user_keys)
  end
end
