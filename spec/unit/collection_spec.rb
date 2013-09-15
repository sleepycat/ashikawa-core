# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/collection'

describe Ashikawa::Core::Collection do
  subject { Ashikawa::Core::Collection }

  before :each do
    @database = double
  end

  it "should have a name" do
    my_collection = subject.new @database, server_response("collections/60768679")
    expect(my_collection.name).to eq("example_1")
  end

  it "should accept an ID" do
    my_collection = subject.new @database, server_response("collections/60768679")
    expect(my_collection.id).to eq("60768679")
  end

  it "should create a query" do
    collection = subject.new @database, server_response("collections/60768679")

    double Ashikawa::Core::Query
    allow(Ashikawa::Core::Query).to receive(:new)
    expect(Ashikawa::Core::Query).to receive(:new).exactly(1).times.with(collection)

    collection.query
  end

  describe "attributes of a collection" do
    it "should check if the collection waits for sync" do
      allow(@database).to receive(:send_request).with("collection/60768679/properties", {}).and_return { server_response("collections/60768679-properties") }
      expect(@database).to receive(:send_request).with("collection/60768679/properties", {})

      my_collection = subject.new @database, { "id" => "60768679" }
      expect(my_collection.wait_for_sync?).to be_true
    end

    it "should know how many documents the collection has" do
      allow(@database).to receive(:send_request).with("collection/60768679/count", {}).and_return { server_response("collections/60768679-count") }
      expect(@database).to receive(:send_request).with("collection/60768679/count", {})

      my_collection = subject.new @database, { "id" => "60768679" }
      expect(my_collection.length).to eq(54)
    end

    it "should know if the collection is volatile" do
      allow(@database).to receive(:send_request).with("collection/60768679/properties", {}).and_return { server_response("collections/60768679-properties-volatile") }
      expect(@database).to receive(:send_request).with("collection/60768679/properties", {})

      my_collection = subject.new(@database, { "id" => "60768679" })
      expect(my_collection.volatile?).to eq(true)
    end

    it "should know if the collection is not volatile" do
      allow(@database).to receive(:send_request).with("collection/60768679/properties", {}).and_return { server_response("collections/60768679-properties") }
      expect(@database).to receive(:send_request).with("collection/60768679/properties", {})

      my_collection = subject.new(@database, { "id" => "60768679" })
      expect(my_collection.volatile?).to eq(false)
    end

    it "should know that a collection is from type 'document'" do
      my_collection = subject.new(@database, { "id" => "60768679", "type" => 2 })
      expect(my_collection.content_type).to eq(:document)
    end

    it "should know that a collection is from type 'edge'" do
      my_collection = subject.new(@database, { "id" => "60768679", "type" => 3 })
      expect(my_collection.content_type).to eq(:edge)
    end

    it "should check for the figures" do
      allow(@database).to receive(:send_request).with("collection/60768679/figures", {}).and_return { server_response("collections/60768679-figures") }
      expect(@database).to receive(:send_request).with("collection/60768679/figures", {}).at_least(1).times

      double Ashikawa::Core::Figure
      allow(Ashikawa::Core::Figure).to receive(:new)
      expect(Ashikawa::Core::Figure).to receive(:new).exactly(1).times.with(server_response("collections/60768679-figures")["figures"])

      my_collection = subject.new @database, { "id" => "60768679" }
      my_collection.figure
    end
  end

  describe "an initialized collection" do
    subject { Ashikawa::Core::Collection.new @database, { "id" => "60768679", "name" => "example_1" } }

    it "should get deleted" do
      allow(@database).to receive(:send_request).with("collection/60768679/", delete: {})
      expect(@database).to receive(:send_request).with("collection/60768679/", delete: {})

      subject.delete
    end

    it "should get loaded" do
      allow(@database).to receive(:send_request).with("collection/60768679/load", put: {})
      expect(@database).to receive(:send_request).with("collection/60768679/load", put: {})

      subject.load
    end

    it "should get unloaded" do
      allow(@database).to receive(:send_request).with("collection/60768679/unload", put: {})
      expect(@database).to receive(:send_request).with("collection/60768679/unload", put: {})

      subject.unload
    end

    it "should get truncated" do
      allow(@database).to receive(:send_request).with("collection/60768679/truncate", put: {})
      expect(@database).to receive(:send_request).with("collection/60768679/truncate", put: {})

      subject.truncate!
    end

    it "should change if it waits for sync" do
      allow(@database).to receive(:send_request).with("collection/60768679/properties", put: {"waitForSync" => true})
      expect(@database).to receive(:send_request).with("collection/60768679/properties", put: {"waitForSync" => true})

      subject.wait_for_sync = true
    end

    it "should check for the key options" do
      raw_key_options = double
      expect(@database).to receive(:send_request).with("collection/60768679/properties", {}).and_return { { "keyOptions" => raw_key_options } }

      key_options = double
      allow(Ashikawa::Core::KeyOptions).to receive(:new).with(raw_key_options).and_return { key_options }

      expect(subject.key_options).to eq(key_options)
    end

    it "should change its name" do
      allow(@database).to receive(:send_request).with("collection/60768679/rename", put: {"name" => "my_new_name"})
      expect(@database).to receive(:send_request).with("collection/60768679/rename", put: {"name" => "my_new_name"})

      subject.name = "my_new_name"
    end

    describe "add and get single documents" do
      it "should receive a document by ID via fetch" do
        allow(@database).to receive(:send_request).with("document/60768679/333", {}).and_return { server_response('documents/example_1-137249191') }
        expect(@database).to receive(:send_request).with("document/60768679/333", {})

        # Documents need to get initialized:
        expect(Ashikawa::Core::Document).to receive(:new)

        subject.fetch(333)
      end

      it "should receive a document by ID via []" do
        allow(@database).to receive(:send_request).with("document/60768679/333", {}).and_return { server_response('documents/example_1-137249191') }
        expect(@database).to receive(:send_request).with("document/60768679/333", {})

        # Documents need to get initialized:
        expect(Ashikawa::Core::Document).to receive(:new)

        subject[333]
      end

      it "should throw an exception when the document was not found during a fetch" do
        allow(@database).to receive(:send_request).and_return {
          raise Ashikawa::Core::DocumentNotFoundException
        }

        expect {
          subject.fetch(123)
        }.to raise_exception Ashikawa::Core::DocumentNotFoundException
      end

      it "should return nil when the document was not found when using []" do
        allow(@database).to receive(:send_request).and_return {
          raise Ashikawa::Core::DocumentNotFoundException
        }

        expect(subject[123]).to be_nil
      end

      it "should replace a document by ID" do
        allow(@database).to receive(:send_request).with("document/60768679/333", put: {"name" => "The Dude"})
        expect(@database).to receive(:send_request).with("document/60768679/333", put: {"name" => "The Dude"})

        subject.replace(333, {"name" => "The Dude"})
      end

      it "should create a new document" do
        document = double
        server_response = { a: 1 }
        raw_document = { b: 2 }

        allow(@database).to receive(:send_request)
          .with("document?collection=60768679", post: raw_document)
          .and_return(server_response)

        expect(Ashikawa::Core::Document).to receive(:new)
          .with(@database, server_response, raw_document)
          .and_return(document)

        subject.create_document(raw_document)
      end

      it "should not create a new edge" do
        expect {
          subject.create_edge(nil, nil, {"quote" => "D'ya have to use s'many cuss words?"})
        }.to raise_exception(RuntimeError, "Can't create an edge in a document collection")
      end

      describe "indices" do
        it "should add a new index" do
          allow(@database).to receive(:send_request).with("index?collection=60768679", post: {
            "type" => "hash", "fields" => [ "a", "b" ]
          }).and_return { server_response('indices/new-hash-index') }
          expect(@database).to receive(:send_request).with("index?collection=60768679", post: {
            "type" => "hash", "fields" => [ "a", "b" ]
          })

          expect(Ashikawa::Core::Index).to receive(:new).with(subject,
            server_response('indices/new-hash-index'))

          subject.add_index :hash, on: [ :a, :b ]
        end

        it "should get an index by ID" do
          allow(@database).to receive(:send_request).with(
            "index/example_1/168054969"
          ).and_return { server_response('indices/hash-index') }

          expect(Ashikawa::Core::Index).to receive(:new).with(subject,
            server_response('indices/hash-index'))

          subject.index 168054969
        end

        it "should get all indices" do
          allow(@database).to receive(:send_request).with(
            "index?collection=60768679"
          ).and_return { server_response('indices/all') }

          expect(Ashikawa::Core::Index).to receive(:new).exactly(1).times

          indices = subject.indices
          expect(indices.length).to eq(1)
        end
      end
    end
  end

  describe "an initialized edge collection" do
    subject { Ashikawa::Core::Collection.new @database, { "id" => "60768679", "name" => "example_1", "type" => 3 } }

    it "should receive an edge by ID" do
      allow(@database).to receive(:send_request).with("edge/60768679/333", {}).and_return { server_response('documents/example_1-137249191') }
      expect(@database).to receive(:send_request).with("edge/60768679/333", {})

      # Documents need to get initialized:
      expect(Ashikawa::Core::Edge).to receive(:new)

      subject.fetch(333)
    end

    it "should replace an edge by ID" do
      allow(@database).to receive(:send_request).with("edge/60768679/333", put: {"name" => "The Dude"})
      expect(@database).to receive(:send_request).with("edge/60768679/333", put: {"name" => "The Dude"})

      subject.replace(333, {"name" => "The Dude"})
    end

    it "should create a new edge" do
      server_response = { a: 1 }
      raw_document = { b: 2 }

      document = double

      allow(@database).to receive(:send_request)
        .with("edge?collection=60768679&from=1&to=2", post: raw_document)
        .and_return(server_response)

      expect(Ashikawa::Core::Edge).to receive(:new)
        .with(@database, server_response, raw_document)
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
