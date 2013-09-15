# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/collection'

describe Ashikawa::Core::Collection do
  let(:database) { double }

  describe "initializing" do
    subject { Ashikawa::Core::Collection }

    it "should have a name" do
      my_collection = subject.new(database, server_response("collections/60768679"))
      expect(my_collection.name).to eq("example_1")
    end

    it "should accept an ID" do
      my_collection = subject.new(database, server_response("collections/60768679"))
      expect(my_collection.id).to eq("60768679")
    end

    it "should create a query" do
      collection = subject.new(database, server_response("collections/60768679"))

      expect(Ashikawa::Core::Query).to receive(:new)
        .exactly(1).times.
        with(collection)

      collection.query
    end

    it "should know that a collection is from type 'document'" do
      my_collection = subject.new(database, { "id" => "60768679", "type" => 2 })
      expect(my_collection.content_type).to eq(:document)
    end

    it "should know that a collection is from type 'edge'" do
      my_collection = subject.new(database, { "id" => "60768679", "type" => 3 })
      expect(my_collection.content_type).to eq(:edge)
    end
  end

  describe "attributes of a collection" do
    subject { Ashikawa::Core::Collection.new database, { "id" => "60768679" } }

    it "should check if the collection waits for sync" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/properties", {})
        .and_return { server_response("collections/60768679-properties") }

      expect(subject.wait_for_sync?).to be_true
    end

    it "should know how many documents the collection has" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/count", {})
        .and_return { server_response("collections/60768679-count") }

      expect(subject.length).to eq(54)
    end

    it "should know if the collection is volatile" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/properties", {})
        .and_return { server_response("collections/60768679-properties-volatile") }

      expect(subject.volatile?).to be_true
    end

    it "should know if the collection is not volatile" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/properties", {})
        .and_return { server_response("collections/60768679-properties") }

      expect(subject.volatile?).to be_false
    end

    it "should check for the figures" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/figures", {})
        .and_return { server_response("collections/60768679-figures") }

      expect(Ashikawa::Core::Figure).to receive(:new).exactly(1).times.with(server_response("collections/60768679-figures")["figures"])

      subject.figure
    end
  end

  describe "an initialized document collection" do
    subject { Ashikawa::Core::Collection.new database, { "id" => "60768679", "name" => "example_1" } }

    let(:raw_key_options) { double }
    let(:key_options) { double }

    it "should get deleted" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/", delete: {})

      subject.delete
    end

    it "should get loaded" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/load", put: {})

      subject.load
    end

    it "should get unloaded" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/unload", put: {})

      subject.unload
    end

    it "should get truncated" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/truncate", put: {})

      subject.truncate!
    end

    it "should change if it waits for sync" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/properties", put: {"waitForSync" => true})

      subject.wait_for_sync = true
    end

    it "should check for the key options" do
      allow(Ashikawa::Core::KeyOptions).to receive(:new)
        .with(raw_key_options)
        .and_return { key_options }

      expect(database).to receive(:send_request)
        .with("collection/60768679/properties", {})
        .and_return { { "keyOptions" => raw_key_options } }

      expect(subject.key_options).to eq(key_options)
    end

    it "should change its name" do
      expect(database).to receive(:send_request)
        .with("collection/60768679/rename", put: {"name" => "my_new_name"})

      subject.name = "my_new_name"
    end

    describe "adding and getting single documents" do
      it "should receive a document by ID via fetch" do
        expect(database).to receive(:send_request)
          .with("document/60768679/333", {})
          .and_return { server_response('documents/example_1-137249191') }
        expect(Ashikawa::Core::Document).to receive(:new)

        subject.fetch(333)
      end

      it "should receive a document by ID via []" do
        expect(database).to receive(:send_request)
          .with("document/60768679/333", {})
          .and_return { server_response('documents/example_1-137249191') }
        expect(Ashikawa::Core::Document).to receive(:new)

        subject[333]
      end

      it "should throw an exception when the document was not found during a fetch" do
        allow(database).to receive(:send_request)
          .and_raise(Ashikawa::Core::DocumentNotFoundException)

        expect {
          subject.fetch(123)
        }.to raise_exception Ashikawa::Core::DocumentNotFoundException
      end

      it "should return nil when the document was not found when using []" do
        allow(database).to receive(:send_request)
          .and_raise(Ashikawa::Core::DocumentNotFoundException)

        expect(subject[123]).to be_nil
      end

      it "should replace a document by ID" do
        expect(database).to receive(:send_request)
          .with("document/60768679/333", put: {"name" => "The Dude"})

        subject.replace(333, {"name" => "The Dude"})
      end

      it "should create a new document" do
        document = double
        server_response = double
        raw_document = double

        allow(database).to receive(:send_request)
          .with("document?collection=60768679", post: raw_document)
          .and_return(server_response)

        expect(Ashikawa::Core::Document).to receive(:new)
          .with(database, server_response, raw_document)
          .and_return(document)

        subject.create_document(raw_document)
      end

      it "should not create a new edge" do
        expect {
          subject.create_edge(double, double, {"quote" => "D'ya have to use s'many cuss words?"})
        }.to raise_exception(RuntimeError, "Can't create an edge in a document collection")
      end
    end

    describe "indexes" do
      it "should add a new index" do
        expect(database).to receive(:send_request)
          .with("index?collection=60768679", post: {
            "type" => "hash", "fields" => [ "a", "b" ]
          })
          .and_return { server_response('indices/new-hash-index') }

        expect(Ashikawa::Core::Index).to receive(:new).with(subject,
          server_response('indices/new-hash-index'))

        subject.add_index :hash, on: [ :a, :b ]
      end

      it "should get an index by ID" do
        allow(database).to receive(:send_request).with("index/example_1/168054969")
          .and_return { server_response('indices/hash-index') }

        expect(Ashikawa::Core::Index).to receive(:new).with(subject,
          server_response('indices/hash-index'))

        subject.index 168054969
      end

      it "should get all indices" do
        allow(database).to receive(:send_request)
          .with("index?collection=60768679")
          .and_return { server_response('indices/all') }

        expect(Ashikawa::Core::Index).to receive(:new)
          .exactly(1).times

        expect(subject.indices.length).to eq(1)
      end
    end
  end

  describe "an initialized edge collection" do
    subject { Ashikawa::Core::Collection.new database, { "id" => "60768679", "name" => "example_1", "type" => 3 } }

    it "should receive an edge by ID" do
      expect(database).to receive(:send_request)
        .with("edge/60768679/333", {})
        .and_return { server_response('documents/example_1-137249191') }
      expect(Ashikawa::Core::Edge).to receive(:new)

      subject.fetch(333)
    end

    it "should replace an edge by ID" do
      expect(database).to receive(:send_request)
        .with("edge/60768679/333", put: {"name" => "The Dude"})

      subject.replace(333, {"name" => "The Dude"})
    end

    it "should create a new edge" do
      server_response = double
      raw_document = double
      document = double

      allow(database).to receive(:send_request)
        .with("edge?collection=60768679&from=1&to=2", post: raw_document)
        .and_return(server_response)

      expect(Ashikawa::Core::Edge).to receive(:new)
        .with(database, server_response, raw_document)
        .and_return(document)

      subject.create_edge(double(id: "1"), double(id: "2"), raw_document)
    end

    it "should not create a new document" do
      expect {
        subject.create_document({"quote" => "D'ya have to use s'many cuss words?"})
      }.to raise_exception(RuntimeError, "Can't create a document in an edge collection")
    end
  end
end
