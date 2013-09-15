# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/edge'

describe Ashikawa::Core::Edge do
  let(:database) { double }
  let(:raw_data) {
    {
      "_id" => "1234567/2345678",
      "_key" => "2345678",
      "_rev" => "3456789",
      "_from" => "7848004/9289796",
      "_to" => "7848004/9355332",
      "first_name" => "The",
      "last_name" => "Dude"
    }
  }
  let(:additional_data) {
    {
      more_info: "this is important"
    }
  }

  describe "initializing" do
    subject { Ashikawa::Core::Edge }

    it "should initialize data" do
      document = subject.new(database, raw_data, additional_data)
      expect(document.id).to eq("1234567/2345678")
      expect(document.key).to eq("2345678")
      expect(document.revision).to eq("3456789")
      expect(document["more_info"]).to eq(additional_data[:more_info])
    end
  end

  describe "initialized edge" do
    subject { Ashikawa::Core::Edge.new(database, raw_data)}

    it "should be deletable" do
      expect(database).to receive(:send_request).with("edge/#{raw_data['_id']}",
        { delete: {} }
      )

      subject.delete
    end

    it "should store changes to the database" do
      expect(database).to receive(:send_request).with("edge/#{raw_data['_id']}",
        { put: { "first_name" => "The", "last_name" => "Other" } }
      )

      subject["last_name"] = "Other"
      subject.save
    end

    it "should know the ID of the 'from' document" do
      expect(subject.from_id).to eq("7848004/9289796")
    end

    it "should know the ID of the 'to' document" do
      expect(subject.to_id).to eq("7848004/9355332")
    end
  end
end
