# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/graph'
require 'ashikawa-core/database'

describe Ashikawa::Core::Graph do
  let(:database) { instance_double('Ashikawa::Core::Database') }
  let(:raw_graph) { double('RawGraph').as_null_object }
  let(:edge_definition) do
    {
      'collection' => 'friends',
      'from'       => ['ponies'],
      'to'         => ['dragons', 'ponies']
    }
  end

  def collection_double(name)
    instance_double('Ashikawa::Core::VertexCollection', name: name.to_s)
  end

  def edge_collection_double(name)
    instance_double('Ashikawa::Core::EdgeCollection', name: name.to_s)
  end

  context 'an initialized graph' do
    subject { Ashikawa::Core::Graph.new(database, raw_graph) }

    before do
      allow(raw_graph).to receive(:[]).with('name').and_return('my_graph')
      allow(raw_graph).to receive(:[]).with('_rev').and_return('A113')
      allow(raw_graph).to receive(:fetch).with('orphanCollections').and_return(['orphan'])
      allow(raw_graph).to receive(:fetch).with('edgeDefinitions').and_return([edge_definition])
    end

    its(:database) { should eq database }
    its(:name) { should eq 'my_graph' }
    its(:revision) { should eq 'A113' }
    its(:edge_definitions) { should eq [edge_definition] }

    it 'should delegate send_request to the database' do
      expect(database).to receive(:send_request).with('gharial/my_graph')

      subject.send_request 'gharial/my_graph'
    end

    it 'should extract the name from the _key if no name was provided' do
      allow(raw_graph).to receive(:[]).with('name').and_return(nil)
      allow(raw_graph).to receive(:[]).with('_key').and_return('my_graph')
      expect(subject.name).to eq 'my_graph'
    end

    context 'delete the graph' do
      it 'should delete just the graph' do
        expect(database).to receive(:send_request).with('gharial/my_graph', delete: { dropCollections: false })

        subject.delete
      end

      it 'should delete the graph including all collections' do
        expect(database).to receive(:send_request).with('gharial/my_graph', delete: { dropCollections: true })

        subject.delete(drop_collections: true)
      end
    end

    context 'vertex collections' do
      let(:raw_vertex_collection) { double('RawVertexCollection') }

      it 'should have a list of vertex collections' do
        expected_vertex_collection = [collection_double(:ponies), collection_double(:orphan), collection_double(:dragons)]
        allow(subject).to receive(:vertex_collection).and_return(*expected_vertex_collection)

        expect(subject.vertex_collections).to match_array expected_vertex_collection
      end

      it 'should now if a collection has already been added to the list of vertices' do
        allow(subject).to receive(:vertex_collection_names).and_return(['ponies'])

        expect(subject.has_vertex_collection?('dragons')).to be_falsy
        expect(subject.has_vertex_collection?('ponies')).to be_truthy
      end

      context 'fetching a single collection' do
        let(:existing_vertex_collection) { instance_double('Ashikawa::Core::VertexCollection') }

        before do
          allow(database).to receive(:send_request)
            .with('collection/places')
            .and_return(raw_vertex_collection)

          allow(Ashikawa::Core::VertexCollection).to receive(:new)
            .with(database, raw_vertex_collection, subject)
            .and_return(existing_vertex_collection)
        end

        it 'should get a single vertex collection' do
          books_collection = subject.vertex_collection 'places'
          expect(books_collection).to eq existing_vertex_collection
        end
      end

      context 'adding a collection' do
        let(:updated_raw_graph) { double('UpdatedRawGraph') }
        let(:raw_vertex_collection) { double('RawVertexCollection') }
        let(:new_vertex_collection) { instance_double('Ashikawa::Core::VertexCollection') }

        before do
          allow(updated_raw_graph).to receive(:[]).with('name').and_return('my_graph')
          allow(updated_raw_graph).to receive(:[]).with('_rev')
          allow(updated_raw_graph).to receive(:fetch).with('orphanCollections').and_return(['books'])
          allow(updated_raw_graph).to receive(:fetch).with('edgeDefinitions').and_return([edge_definition])

          allow(database).to receive(:send_request)
            .with('gharial/my_graph/vertex', post: { collection: 'books' })
            .and_return({ 'graph' => updated_raw_graph })

          allow(database).to receive(:send_request)
            .with('collection/books')
            .and_return(raw_vertex_collection)

          allow(Ashikawa::Core::VertexCollection).to receive(:new)
            .with(database, raw_vertex_collection, subject)
            .and_return(new_vertex_collection)
        end

        it 'should add the new collection to the vertex collections of the graph' do
          books_collection = collection_double(:books)
          allow(subject).to receive(:vertex_collection).and_return(books_collection)

          subject.add_vertex_collection 'books'

          expect(subject.vertex_collections).to include books_collection
        end

        it 'should return the newly created collection' do
          expect(subject.add_vertex_collection('books')).to eq new_vertex_collection
        end
      end
    end

    context 'edge collections' do
      it 'should have a list of edge collections' do
        expected_edge_collections = [edge_collection_double(:friends)]
        allow(subject).to receive(:edge_collection).and_return(*expected_edge_collections)

        expect(subject.edge_collections).to match_array expected_edge_collections
      end
    end
  end
end
