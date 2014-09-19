# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/vertex_collection'
require 'ashikawa-core/graph'
require 'ashikawa-core/database'

describe Ashikawa::Core::VertexCollection do
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:raw_collection) do
    {
      'id' => '60768679',
      'name' => 'example_1',
      'status' => 3,
      'type' => 2,
      'error' => false,
      'code' => 200
    }
  end
  let(:graph) { instance_double('Ashikawa::Core::Graph') }

  context 'building a vertex collection' do
    before do
      allow(graph).to receive(:has_vertex_collection?).with('example_1').and_return(false)
    end

    it 'should raise an exception if the graph does not now about the collection yet' do
      expect do
        Ashikawa::Core::VertexCollection.new(database, raw_collection, graph)
      end.to raise_exception(Ashikawa::Core::CollectionNotInGraphException)
    end
  end

  context 'an initialized vertex collection' do
    subject { Ashikawa::Core::VertexCollection.new(database, raw_collection, graph) }

    before do
      allow(graph).to receive(:has_vertex_collection?).with('example_1').and_return(true)
    end

    it 'should be a subclass of Collection' do
      expect(subject).to be_kind_of Ashikawa::Core::Collection
    end

    it 'should have a reference to its graph' do
      expect(subject.graph).to eq graph
    end
  end
end
