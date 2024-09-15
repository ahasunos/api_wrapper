# frozen_string_literal: true

require 'spec_helper'
require 'api_wrapper/http_client/base_client'

RSpec.describe ApiWrapper::HttpClient::BaseClient do
  let(:base_url) { 'https://api.example.com' }
  let(:cache_policy) { double('CachePolicy') }

  subject { described_class.new(base_url, cache_policy) }

  describe '#initialize' do
    it 'sets the base_url' do
      expect(subject.instance_variable_get(:@base_url)).to eq(base_url)
    end

    it 'sets the cache_policy' do
      expect(subject.instance_variable_get(:@cache_policy)).to eq(cache_policy)
    end
  end

  describe '#get' do
    it 'raises NotImplementedError when calling get' do
      expect do
        subject.get('/endpoint')
      end.to raise_error(NotImplementedError, 'Subclasses must implement the get method')
    end
  end
end
