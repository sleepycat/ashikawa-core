require 'unit/spec_helper'
require 'ashikawa-core/document'

describe Ashikawa::Core::Document do
  let(:database) { double }
  let(:raw_data) {
    {
      "_id" => "1234567/2345678",
      "_key" => "2345678",
      "_rev" => "3456789",
      "first_name" => "The",
      "last_name" => "Dude"
    }
  }
  let(:raw_data_without_id) {
    {
      "first_name" => "The",
      "last_name" => "Dude"
    }
  }
  subject { Ashikawa::Core::Document }

  it "should initialize data with ID" do
    document = subject.new database, raw_data
    expect(document.id).to eq("1234567/2345678")
    expect(document.key).to eq("2345678")
    expect(document.revision).to eq("3456789")
  end

  it "should initialize data without ID" do
    document = subject.new database, raw_data_without_id
    expect(document.id).to eq(:not_persisted)
    expect(document.revision).to eq(:not_persisted)
  end

  describe "initialized document with ID" do
    subject { Ashikawa::Core::Document.new database, raw_data }

    it "should return the correct value for an existing attribute" do
      expect(subject["first_name"]).to be(raw_data["first_name"])
    end

    it "should return nil for an non-existing attribute" do
      expect(subject["no_name"]).to be_nil
    end

    it "should be deletable" do
      expect(database).to receive(:send_request).with("document/#{raw_data['_id']}",
        { delete: {} }
      )

      subject.delete
    end

    it "should store changes to the database" do
      expect(database).to receive(:send_request).with("document/#{raw_data['_id']}",
        { put: { "first_name" => "The", "last_name" => "Other" } }
      )

      subject["last_name"] = "Other"
      subject.save
    end

    it "should be convertable to a hash" do
      hash = subject.hash
      expect(hash).to be_instance_of Hash
      expect(hash["first_name"]).to eq(subject["first_name"])
    end

    it "should be refreshable" do
      expect(database).to receive(:send_request).with("document/#{raw_data['_id']}", {}).and_return {
        { "name" => "Jeff" }
      }

      refreshed_subject = subject.refresh!
      expect(refreshed_subject).to eq(subject)
      expect(subject["name"]).to eq("Jeff")
    end
  end

  describe "initialized document without ID" do
    subject { Ashikawa::Core::Document.new database, raw_data_without_id }

    it "should return the correct value for an existing attribute" do
      expect(subject["first_name"]).to be(raw_data_without_id["first_name"])
    end

    it "should return nil for an non-existing attribute" do
      expect(subject["no_name"]).to be_nil
    end

    it "should not be deletable" do
      expect(database).not_to receive :send_request
      expect { subject.delete }.to raise_error Ashikawa::Core::DocumentNotFoundException
    end

    it "should not store changes to the database" do
      expect(database).not_to receive :send_request
      expect { subject.save }.to raise_error Ashikawa::Core::DocumentNotFoundException
    end
  end
end
