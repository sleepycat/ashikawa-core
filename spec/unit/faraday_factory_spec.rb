# -*- encoding : utf-8 -*-
require 'unit/spec_helper'
require 'ashikawa-core/faraday_factory'

describe Ashikawa::Core::FaradayFactory do
  describe 'initializing Faraday' do
    subject { Ashikawa::Core::FaradayFactory }
    let(:adapter) { double('Adapter') }
    let(:logger) { double('Logger') }
    let(:blocky) { double('Block') }
    let(:api_string) { double('ApiString') }

    it 'should initialize with specific logger and adapter' do
      expect(Faraday).to receive(:new).with(api_string).and_yield(blocky)
      expect(blocky).to receive(:request).with(:json)
      expect(blocky).to receive(:response).with(:minimal_logger, logger, debug_headers: false)
      expect(blocky).to receive(:response).with(:error_response)
      expect(blocky).to receive(:response).with(:json)
      expect(blocky).to receive(:adapter).with(adapter)

      subject.create_connection(api_string, adapter: adapter, logger: logger)
    end

    it 'should initialize with defaults when no specific logger and adapter was given' do
      expect(Faraday).to receive(:new).with(api_string).and_yield(blocky)
      expect(blocky).to receive(:request).with(:json)
      expect(blocky).to receive(:response).with(:error_response)
      expect(blocky).to receive(:response).with(:json)
      expect(blocky).to receive(:adapter).with(Faraday.default_adapter)

      subject.create_connection(api_string, {})
    end

    it 'should allow to add additional request middlewares' do
      allow(Faraday).to receive(:new).with(api_string).and_yield(blocky)
      allow(blocky).to receive(:request).with(:json)
      allow(blocky).to receive(:response).with(:error_response)
      allow(blocky).to receive(:response).with(:json)
      allow(blocky).to receive(:adapter).with(Faraday.default_adapter)
      expect(blocky).to receive(:request).with(:my_middleware, :options)

      subject.create_connection(api_string, additional_request_middlewares: [[:my_middleware, :options]])
    end
  end
end
