# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/configuration'

describe Ashikawa::Core::Configuration do
  let(:url) { double }
  let(:logger) { double }
  let(:adapter) { double }
  let(:connection) { double }
  let(:username) { double }
  let(:password) { double }

  its(:url) { should be_nil }
  its(:logger) { should be_nil }
  its(:adapter) { should be_nil }

  it "should raise an Argument error if the URL is missing" do
    expect {
      subject.connection
    }.to raise_error(ArgumentError, /either an url or a connection/)
  end

  describe "provided with connection" do
    before { subject.connection = connection }
    its(:connection) { should be connection }
  end

  describe "provided with url, logger and adapter" do
    before {
      subject.url = url
      subject.logger = logger
      subject.adapter = adapter
    }

    its(:url) { should be url }
    its(:logger) { should be logger }
    its(:adapter) { should be adapter }

    it "should construct a connection" do
      expect(Ashikawa::Core::Connection).to receive(:new)
        .with(url, { logger: logger, adapter: adapter })
        .and_return(connection)
      expect(subject.connection).to be connection
    end
  end

  describe "set up authentication" do
    before do
      subject.url = url
      allow(Ashikawa::Core::Connection).to receive(:new)
        .and_return(connection)
    end

    it "should setup authentication" do
      expect(connection).to receive(:authenticate_with)
        .with({ username: username, password: password })
        .and_return(connection)

      subject.username = username
      subject.password = password
      subject.connection
    end
  end
end
