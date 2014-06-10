# -*- encoding : utf-8 -*-

require 'unit/spec_helper'
require 'ashikawa-core/minimal_logger'

class FakeLogger
  attr_reader :output

  def debug(progname = nil, &block)
    @output = block.call
  end
end

describe Ashikawa::Core::MinimalLogger do
  let(:app)    { double('App') }
  let(:logger) { FakeLogger.new }
  let(:env)    { double('Env', method: 'get', url: 'http://localhost/_db/test', status: 200, request_headers: {}, response_headers: {}) }

  subject { Ashikawa::Core::MinimalLogger.new(app, logger) }

  before do
    allow(app).to receive(:call).and_return(app)
    allow(app).to receive(:on_complete)
  end

  it 'should log the request upon call' do
    subject.call env

    expect(logger.output).to eq 'GET http://localhost/_db/test'
  end

  it 'should log the response on complete' do
    subject.on_complete env

    expect(logger.output).to eq 'GET http://localhost/_db/test 200'
  end

  context 'with debug_headers' do
    subject { Ashikawa::Core::MinimalLogger.new(app, logger, debug_headers: true) }

    it 'should log the request upon call with headers' do
      allow(env).to receive(:request_headers).and_return(bar: 'foo')
      subject.call env

      expect(logger.output).to eq 'GET http://localhost/_db/test bar: "foo"'
    end

    it 'should log the response on complete with headers' do
      allow(env).to receive(:response_headers).and_return(bar: 'foo')
      subject.on_complete env

      expect(logger.output).to eq 'GET http://localhost/_db/test 200 bar: "foo"'
    end
  end
end
