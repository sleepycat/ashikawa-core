# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/index'

describe Ashikawa::Core::Index do
  let(:collection) { double }
  let(:raw_data) {
    {
      "code" => 201,
      "fields" => [
        "something"
      ],
      "id" => "167137465/168054969",
      "type" => "hash",
      "isNewlyCreated" => true,
      "unique" => true,
      "error" => false
    }
  }
  subject { Ashikawa::Core::Index }

  it "should initialize an Index" do
    index = subject.new collection, raw_data
    expect(index.id).to eq("167137465/168054969")
    expect(index.type).to eq(:hash)
    expect(index.on).to eq([:something])
    expect(index.unique).to eq(true)
  end

  describe "initialized index" do
    subject { Ashikawa::Core::Index.new collection, raw_data }

    it "should be deletable" do
      expect(collection).to receive(:send_request).with("index/167137465/168054969",
        delete: {})

      subject.delete
    end
  end
end
