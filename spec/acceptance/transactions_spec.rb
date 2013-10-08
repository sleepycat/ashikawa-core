# -*- encoding : utf-8 -*-
require 'acceptance/spec_helper'

describe 'Transactions' do
  subject { DATABASE }

  before :each do
    subject.collections.each { |collection| collection.delete }
    subject['collection_1']
    subject['collection_2']
    subject['collection_3']
  end

  let(:js_function) { 'function (x) { return x.a; }' }
  let(:write_collections) { %w{collection_1 collection_2} }
  let(:read_collections) { %w{collection_2} }

  it 'should create and execute a transaction' do
    transaction = subject.create_transaction js_function, write: write_collections, read: read_collections

    transaction.wait_for_sync = true
    transaction.lock_timeout = 14

    expect(transaction.execute({ a: 5 })).to eq(5)
  end
end
