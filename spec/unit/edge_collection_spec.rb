# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/edge_collection'
require 'ashikawa-core/graph'
require 'ashikawa-core/database'

describe Ashikawa::Core::EdgeCollection do
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:raw_collection) do
    {
      'id' => '60768679',
      'name' => 'example_1',
      'status' => 3,
      'type' => 3,
      'error' => false,
      'code' => 200
    }
  end
  let(:graph) { instance_double('Ashikawa::Core::Graph') }

  context 'an initialized edge collection' do
    subject { Ashikawa::Core::EdgeCollection.new(database, raw_collection, graph) }

    it 'should be a subclass of Collection' do
      expect(subject).to be_kind_of Ashikawa::Core::Collection
    end

    it 'should have a reference to its graph' do
      expect(subject.graph).to eq graph
    end
  end
end

