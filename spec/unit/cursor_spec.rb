# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/cursor'

describe Ashikawa::Core::Cursor do
  subject { Ashikawa::Core::Cursor }

  before :each do
    @database = double
    double Ashikawa::Core::Document
  end

  it "should create a cursor for a non-complete batch" do
    my_cursor = subject.new @database, server_response("cursor/26011191")
    expect(my_cursor.id).to        eq("26011191")
    expect(my_cursor.length).to    eq(5)
  end

  it "should create a cursor for the last batch" do
    my_cursor = subject.new @database, server_response("cursor/26011191-3")
    expect(my_cursor.id).to be_nil
    expect(my_cursor.length).to eq(5)
  end

  describe "existing cursor" do
    subject { Ashikawa::Core::Cursor.new @database,
      server_response("cursor/26011191")
    }

    it "should iterate over all documents of a cursor when given a block" do
      first = true

      allow(@database).to receive(:send_request).with("cursor/26011191", put: {}) do
        if first
          first = false
          server_response("cursor/26011191-2")
        else
          server_response("cursor/26011191-3")
        end
      end
      expect(@database).to receive(:send_request).twice

      allow(Ashikawa::Core::Document).to receive(:new)
      expect(Ashikawa::Core::Document).to receive(:new).exactly(5).times

      subject.each { |document| }
    end

    it "should return an enumerator to go over all documents of a cursor when given no block" do
      first = true

      allow(@database).to receive(:send_request).with("cursor/26011191", put: {}) do
        if first
          first = false
          server_response("cursor/26011191-2")
        else
          server_response("cursor/26011191-3")
        end
      end
      expect(@database).to receive(:send_request).twice

      allow(Ashikawa::Core::Document).to receive(:new)
      expect(Ashikawa::Core::Document).to receive(:new).exactly(5).times

      enumerator = subject.each
      enumerator.next
      enumerator.next
      enumerator.next
      enumerator.next
      enumerator.next
      expect { enumerator.next }.to raise_exception(StopIteration)
    end

    it "should be deletable" do
      allow(@database).to receive(:send_request)
      expect(@database).to receive(:send_request).with("cursor/26011191",
        delete: {})

      subject.delete
    end

    it "should be enumerable" do
      first = true

      allow(@database).to receive(:send_request).with("cursor/26011191", put: {}) do
        if first
          first = false
          server_response("cursor/26011191-2")
        else
          server_response("cursor/26011191-3")
        end
      end
      expect(@database).to receive(:send_request).twice

      allow(Ashikawa::Core::Document).to receive(:new).and_return { 1 }
      expect(Ashikawa::Core::Document).to receive(:new).exactly(5).times

      expect(subject.map{|i| i}[0]).to eq(1)
    end

    it "should return edge objects when recieving data from an edge collection" do
      allow(@database).to receive(:send_request).with("cursor/26011191", put: {}) do
        server_response("cursor/edges")
      end
      expect(@database).to receive(:send_request).once

      allow(Ashikawa::Core::Edge).to receive(:new).and_return { 1 }
      expect(Ashikawa::Core::Edge).to receive(:new).exactly(2).times

      subject.each { |document| }
    end

  end
end
