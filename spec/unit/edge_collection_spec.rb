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

      it 'should return the edge documents' do
        created_edges = subject.add(from: this_document, to: that_document)

        expect(created_edges).to eq new_edge
      end
    end

    context 'removing edges by example' do
      let(:this_document) { instance_double('Ashikawa::Core::Document', id: 'this_document_id') }
      let(:that_document) { instance_double('Ashikawa::Core::Document', id: 'that_document_id') }
      let(:query)         { double('Query') }
      let(:aql_string)    do
        <<-AQL.gsub(/^[ \t]*/, '')
        FOR e IN @@edge_collection
          FILTER e._from == @from && e._to == @to
          REMOVE e._key IN @@edge_collection
        AQL
      end
      let(:bind_vars) { { :'@edge_collection' => 'relation', :from => 'this_document_id', :to => 'that_document_id' } }

      before do
        allow(database).to receive(:query).and_return(query)
      end

      it 'should remove the edges' do
        expect(query).to receive(:execute)
          .with(aql_string, bind_vars: bind_vars)

        subject.remove(from: this_document, to: that_document)
      end
    end

    it 'should overwrite #send_request_for_this_collection to use gharial' do
      expect(subject).to receive(:send_request)
        .with('gharial/my_graph/edge/relation/edge_key', {})

      subject.send(:send_request_for_this_collection, 'edge_key')
    end

    it 'should overwrite the #build_content_class to create edges with the graph attached' do
      expect(Ashikawa::Core::Edge).to receive(:new)
        .with(database, raw_edge, graph: graph)
        .and_return(new_edge)

      subject.build_content_class(raw_edge)
    end
  end
end
