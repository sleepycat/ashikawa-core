require 'unit/spec_helper'
require 'ashikawa-core/query'

describe Ashikawa::Core::Query do
  let(:collection) { double }
  let(:database) { double }

  describe "initialized with collection" do
    subject { Ashikawa::Core::Query.new collection }

    before do
      allow(collection).to receive(:name).and_return "example_1"
      allow(collection).to receive(:database).and_return double
    end

    describe "get all" do
      it "should list all documents" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/all') }
        expect(collection).to receive(:send_request).with("simple/all", put: {"collection" => "example_1"})

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.all
      end

      it "should be able to limit the number of documents" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/all_skip') }
        expect(collection).to receive(:send_request).with("simple/all", put: {"collection" => "example_1", "limit" => 1})

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.all limit: 1
      end

      it "should be able to skip documents" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/all_limit') }
        expect(collection).to receive(:send_request).with("simple/all", put: {"collection" => "example_1", "skip" => 1})

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.all skip: 1
      end
    end

    describe "first by example" do
      let(:example) { {hello: "world"} }

      it "should find exactly one fitting document" do
        allow(collection).to receive(:database).and_return { double }

        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/example') }
        expect(collection).to receive(:send_request).with("simple/first-example", put:
          {"collection" => "example_1", "example" => { hello: "world"}})

        expect(Ashikawa::Core::Document).to receive(:new)

        subject.first_example example
      end
    end

    describe "all by example" do
      let(:example) { {hello: "world"} }

      it "should find all fitting documents" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/example') }
        expect(collection).to receive(:send_request).with("simple/by-example", put:
          {"collection" => "example_1", "example" => { hello: "world"}})

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.by_example example
      end

      it "should be able to limit the number of documents" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/example') }
        expect(collection).to receive(:send_request).with("simple/by-example", put: {"collection" => "example_1", "limit" => 2, "example" => { hello: "world"}})

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.by_example example, limit: 2
      end

      it "should be able to skip documents" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/example') }
        expect(collection).to receive(:send_request).with("simple/by-example", put:
          {"collection" => "example_1", "skip" => 1, "example" => { hello: "world"}})

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.by_example example, skip: 1
      end
    end

    describe "near a geolocation" do
      it "should find documents based on latitude/longitude" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/near') }
        expect(collection).to receive(:send_request).with("simple/near", put: { "collection" => "example_1", "latitude" => 0, "longitude" => 0 })

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.near latitude: 0, longitude: 0
      end
    end

    describe "within a radious of a geolocation" do
      it "should look for documents based on latidude/longitude" do
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/within') }
        expect(collection).to receive(:send_request).with("simple/within" , put: { "collection" => "example_1", "latitude" => 0, "longitude" => 0, "radius" => 2 })

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.within latitude: 0, longitude: 0, radius: 2
      end
    end

    describe "in a certain range" do
      it "should look for documents with an attribute in that range" do
        arguments = { "collection" => "example_1", "attribute" => "age", "left" => 50, "right" => 60, "closed" => false}
        allow(collection).to receive(:send_request).and_return { server_response('simple-queries/range') }
        expect(collection).to receive(:send_request).with("simple/range" , put: arguments)

        expect(Ashikawa::Core::Cursor).to receive(:new)

        subject.in_range attribute: "age", left: 50, right: 60, closed: false
      end
    end

    describe "with an AQL query" do
      it "should be able to execute it" do
        allow(collection).to receive(:database).and_return double
        allow(collection).to receive(:send_request).and_return { server_response("cursor/query") }
        expect(collection).to receive(:send_request).with("cursor", post: {
          "query" => "FOR u IN users LIMIT 2 RETURN u",
          "count" => true,
          "batchSize" => 2
        })
        expect(Ashikawa::Core::Cursor).to receive(:new).with(collection.database, server_response("cursor/query"))

        subject.execute "FOR u IN users LIMIT 2 RETURN u", count: true, batch_size: 2
      end

      it "should return true when asked if a valid query is valid" do
        query = "FOR u IN users LIMIT 2 RETURN u"

        allow(collection).to receive(:send_request).and_return { server_response("query/valid") }
        expect(collection).to receive(:send_request).with("query", post: {
          "query" => query
        })

        expect(subject.valid?(query)).to be_true
      end

      it "should return false when asked if an invalid query is valid" do
        query = "FOR u IN users LIMIT 2"

        allow(collection).to receive(:send_request) do
          raise Ashikawa::Core::BadSyntax
        end
        expect(collection).to receive(:send_request).with("query", post: {
          "query" => query
        })

        expect(subject.valid?(query)).to be_false
      end
    end
  end

  describe "initialized with database" do
    subject { Ashikawa::Core::Query.new database}

    it "should throw an exception when a simple query is executed" do
      [:all, :by_example, :first_example, :near, :within, :in_range].each do |method|
        expect { subject.send method }.to raise_error Ashikawa::Core::NoCollectionProvidedException
      end
    end

    describe "with an AQL query" do
      it "should be able to execute it" do
        allow(database).to receive(:send_request).and_return { server_response("cursor/query") }
        expect(database).to receive(:send_request).with("cursor", post: {
          "query" => "FOR u IN users LIMIT 2 RETURN u",
          "count" => true,
          "batchSize" => 2
        })
        expect(Ashikawa::Core::Cursor).to receive(:new).with(database, server_response("cursor/query"))

        subject.execute "FOR u IN users LIMIT 2 RETURN u", count: true, batch_size: 2
      end

      it "should return true when asked if a valid query is valid" do
        query = "FOR u IN users LIMIT 2 RETURN u"

        allow(database).to receive(:send_request).and_return { server_response("query/valid") }
        expect(database).to receive(:send_request).with("query", post: {
          "query" => query
        })

        expect(subject.valid?(query)).to be_true
      end

      it "should return false when asked if an invalid query is valid" do
        query = "FOR u IN users LIMIT 2"

        allow(database).to receive(:send_request) do
          raise Ashikawa::Core::BadSyntax
        end
        expect(database).to receive(:send_request).with("query", post: {
          "query" => query
        })

        expect(subject.valid?(query)).to be_false
      end
    end
  end
end
