require 'unit/spec_helper'
require 'ashikawa-core/database'

describe Ashikawa::Core::Database do
  subject { Ashikawa::Core::Database }

  before :each do
    double(Ashikawa::Core::Connection)
    double(Ashikawa::Core::Collection)
    double(Ashikawa::Core::Cursor)
    double(Ashikawa::Core::Transaction)
    @connection = double("connection", host: "localhost", port: 8529, scheme: "http")
  end

  it "should initialize with a connection" do
    allow(@connection).to receive(:host) { "localhost" }
    allow(@connection).to receive(:port) { 8529 }

    database = subject.new do |config|
      config.connection = @connection
    end
    expect(database.host).to eq("localhost")
    expect(database.port).to eq(8529)
  end

  it "should initialize with a connection string" do
    allow(Ashikawa::Core::Connection).to receive(:new).with("http://localhost:8529", {
      logger: nil,
      adapter: nil
    }).and_return(double)
    expect(Ashikawa::Core::Connection).to receive(:new).with("http://localhost:8529", {
      logger: nil,
      adapter: nil
    })

    subject.new do |config|
      config.url = "http://localhost:8529"
    end
  end

  it "should initialize with a connection string and logger" do
    logger = double
    allow(Ashikawa::Core::Connection).to receive(:new).with("http://localhost:8529", {
      logger: logger,
      adapter: nil
    }).and_return(double)
    expect(Ashikawa::Core::Connection).to receive(:new).with("http://localhost:8529", {
      logger: logger,
      adapter: nil
    })

    subject.new do |config|
      config.url = "http://localhost:8529"
      config.logger = logger
    end
  end

  it "should initialize with a connection string and adapter" do
    adapter = double
    allow(Ashikawa::Core::Connection).to receive(:new).with("http://localhost:8529", {
      logger: nil,
      adapter: adapter
    }).and_return(double)
    expect(Ashikawa::Core::Connection).to receive(:new).with("http://localhost:8529", {
      logger: nil,
      adapter: adapter
    })

    subject.new do |config|
      config.url = "http://localhost:8529"
      config.adapter = adapter
    end
  end

  it "should throw an argument error when neither url nor connection was provided" do
    adapter = double
    logger = double

    expect {
      subject.new do |config|
        config.adapter = adapter
        config.logger = logger
      end
    }.to raise_error(ArgumentError, /either an url or a connection/)
  end

  it "should create a query" do
    database = subject.new do |config|
      config.connection = @connection
    end

    double Ashikawa::Core::Query
    allow(Ashikawa::Core::Query).to receive(:new)
    expect(Ashikawa::Core::Query).to receive(:new).exactly(1).times.with(database)

    database.query
  end

  describe "initialized database" do
    subject {
      Ashikawa::Core::Database.new do |config|
        config.connection = @connection
      end
    }

    it "should delegate authentication to the connection" do
      expect(@connection).to receive(:authenticate_with).with({ username: "user", password: "password" })

      subject.authenticate_with username: "user", password: "password"
    end

    it "should fetch all available non-system collections" do
      allow(@connection).to receive(:send_request) {|path| server_response("collections/all") }
      expect(@connection).to receive(:send_request).with("collection")

      (0..1).each do |k|
        expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/all")["collections"][k])
      end

      expect(subject.collections.length).to eq(2)
    end

    it "should fetch all available non-system collections" do
      allow(@connection).to receive(:send_request) {|path| server_response("collections/all") }
      expect(@connection).to receive(:send_request).with("collection")

      expect(Ashikawa::Core::Collection).to receive(:new).exactly(5).times

      expect(subject.system_collections.length).to eq(5)
    end

    it "should create a non volatile collection by default" do
      allow(@connection).to receive(:send_request) { |path| server_response("collections/60768679") }
      expect(@connection).to receive(:send_request).with("collection",
        post: { name: "volatile_collection"})

      expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/60768679"))

      subject.create_collection("volatile_collection")
    end

    it "should create a volatile collection when asked" do
      allow(@connection).to receive(:send_request) { |path| server_response("collections/60768679") }
      expect(@connection).to receive(:send_request).with("collection",
        post: { name: "volatile_collection", isVolatile: true})

      expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/60768679"))

      subject.create_collection("volatile_collection", is_volatile: true)
    end

    it "should create an autoincrement collection when asked" do
      expect(@connection).to receive(:send_request).with("collection",
        post: { name: "autoincrement_collection", keyOptions: {
          type: "autoincrement",
          offset: 0,
          increment: 10,
          allowUserKeys: false
        }
      })

      expect(Ashikawa::Core::Collection).to receive(:new)

      subject.create_collection("autoincrement_collection", key_options: {
        type: :autoincrement,
        offset: 0,
        increment: 10,
        allow_user_keys: false
      })
    end

    it "should create an edge collection when asked" do
      allow(@connection).to receive(:send_request) { |path| server_response("collections/60768679") }
      expect(@connection).to receive(:send_request).with("collection",
        post: { name: "volatile_collection", type: 3})

      expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/60768679"))

      subject.create_collection("volatile_collection", content_type: :edge)
    end

    it "should fetch a single collection if it exists" do
      allow(@connection).to receive(:send_request) { |path| server_response("collections/60768679") }
      expect(@connection).to receive(:send_request).with("collection/60768679")

      expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/60768679"))

      subject.collection(60768679)
    end

    it "should fetch a single collection with the array syntax" do
      allow(@connection).to receive(:send_request) { |path| server_response("collections/60768679") }
      expect(@connection).to receive(:send_request).with("collection/60768679")

      expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/60768679"))

      subject[60768679]
    end

    it "should create a single collection if it doesn't exist" do
      allow(@connection).to receive :send_request do |path, method|
        method ||= {}
        if method.key? :post
          server_response("collections/60768679")
        else
          raise Ashikawa::Core::CollectionNotFoundException
        end
      end
      expect(@connection).to receive(:send_request).with("collection/new_collection")
      expect(@connection).to receive(:send_request).with("collection", post: { name: "new_collection"})

      expect(Ashikawa::Core::Collection).to receive(:new).with(subject, server_response("collections/60768679"))

      subject['new_collection']
    end

    it "should send a request via the connection object" do
      expect(@connection).to receive(:send_request).with("my/path", post: { data: "mydata" })

      subject.send_request "my/path", post: { data: "mydata" }
    end

    let(:js_function) { double }
    let(:collections) { double }
    let(:transaction) { double }

    it "should create a transaction" do
      expect(Ashikawa::Core::Transaction).to receive(:new).with(subject, js_function, collections).and_return { transaction }
      expect(subject.create_transaction(js_function, collections)).to eq(transaction)
    end
  end
end
