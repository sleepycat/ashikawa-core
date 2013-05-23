require 'unit/spec_helper'
require 'ashikawa-core/key_options'

describe Ashikawa::Core::KeyOptions do
  subject { Ashikawa::Core::KeyOptions }

  it "should parse the key options" do
    type = double
    offset = double
    increment = double
    allowUserKeys = double

    keyOptions = subject.new({
      "type" => type,
      "offset" => offset,
      "increment" => increment,
      "allowUserKeys" => allowUserKeys
    })

    keyOptions.type.should == type
    keyOptions.offset.should == offset
    keyOptions.increment.should == increment
    keyOptions.allow_user_keys.should == allowUserKeys
  end
end
