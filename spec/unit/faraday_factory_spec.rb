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

    it 'should initalize with specific logger and adapter' do
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
  end
end
