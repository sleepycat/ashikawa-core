# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/edge_collection'
require 'ashikawa-core/document'
require 'ashikawa-core/graph'
require 'ashikawa-core/database'

describe Ashikawa::Core::EdgeCollection do
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:raw_collection) do
    {
      'id' => '60768679',
      'name' => 'relation',
      'status' => 3,
      'type' => 3,
      'error' => false,
      'code' => 200
    }
  end
  let(:graph) { instance_double('Ashikawa::Core::Graph', name: 'my_graph') }
  let(:raw_edge) { double('RawEdge') }

  context 'an initialized edge collection' do
    subject { Ashikawa::Core::EdgeCollection.new(database, raw_collection, graph) }

    it 'should be a subclass of Collection' do
      expect(subject).to be_kind_of Ashikawa::Core::Collection
    end

    it 'should have a reference to its graph' do
      expect(subject.graph).to eq graph
    end

    context 'adding edges' do
      let(:this_document) { instance_double('Ashikawa::Core::Document', id: 'this_document_id') }
      let(:that_document) { instance_double('Ashikawa::Core::Document', id: 'that_document_id') }
      let(:more_document) { instance_double('Ashikawa::Core::Document', id: 'more_document_id') }

      before do
        allow(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation', post: { _from: 'this_document_id', _to: 'that_document_id' })
          .and_return(raw_edge)
      end

      it 'should add a directed relation between to vertices' do
        expect(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation', post: { _from: 'this_document_id', _to: 'that_document_id' })
          .and_return(raw_edge)

        subject.add(from: this_document, to: that_document)
      end

      it 'should add directed relations between a bunch of vertices' do
        expect(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation', post: { _from: 'this_document_id', _to: 'that_document_id' })
          .and_return(raw_edge)

        expect(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation', post: { _from: 'this_document_id', _to: 'more_document_id' })
          .and_return(raw_edge)

        subject.add(from: this_document, to: [that_document, more_document])
      end

      it 'should return the edge document'
    end
  end
end

