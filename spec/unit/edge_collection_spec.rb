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
  let(:new_edge) { instance_double('Ashikawa::Core::Edge') }
  let(:raw_edge) { double('RawEdge') }
  let(:post_response) { { 'edge' => { '_key' => '123' } } }

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
          .with('gharial/my_graph/edge/relation/', post: { _from: 'this_document_id', _to: 'that_document_id' })
          .and_return(post_response)


        allow(subject).to receive(:fetch)
          .with('123')
          .and_return(new_edge)
      end

      it 'should add a directed relation between to vertices' do
        expect(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation/', post: { _from: 'this_document_id', _to: 'that_document_id' })
          .and_return(post_response)

        subject.add(from: this_document, to: that_document)
      end

      it 'should add directed relations between a bunch of vertices' do
        expect(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation/', post: { _from: 'this_document_id', _to: 'that_document_id' })
          .and_return(post_response)

        expect(subject).to receive(:send_request)
          .with('gharial/my_graph/edge/relation/', post: { _from: 'this_document_id', _to: 'more_document_id' })
          .and_return(post_response)

        subject.add(from: this_document, to: [that_document, more_document])
      end

      it 'should return the edge documents' do
        created_edges = subject.add(from: this_document, to: that_document)

        expect(created_edges).to eq [new_edge]
      end
    end

    it 'should overwrite #send_request_for_this_collection to use gharial' do
      expect(subject).to receive(:send_request)
        .with('gharial/my_graph/edge/relation/edge_key', {})

      subject.send(:send_request_for_this_collection, 'edge_key')
    end
  end
end

