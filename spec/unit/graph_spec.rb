# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/graph'
require 'ashikawa-core/database'

describe Ashikawa::Core::Graph do
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:raw_graph) { double('RawGraph').as_null_object }

  context 'an initialized graph' do
    subject { Ashikawa::Core::Graph.new(database, raw_graph) }

    it 'should know its database' do
      expect(subject.database).to eq database
    end

    it 'should delegate send_request to the database' do
      expect(database).to receive(:send_request).with('gharial/my_graph')

      subject.send_request 'gharial/my_graph'
    end

    it 'should know the name of the graph' do
      allow(raw_graph).to receive(:[]).with('name').and_return('my_graph')
      expect(subject.name).to eq 'my_graph'
    end

    it 'should extract the name from the _key if no name was provided' do
      allow(raw_graph).to receive(:[]).with('name').and_return(nil)
      allow(raw_graph).to receive(:[]).with('_key').and_return('my_graph')
      expect(subject.name).to eq 'my_graph'
    end

    it 'should'
  end
end
