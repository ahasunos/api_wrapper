# frozen_string_literal: true

require 'spec_helper'
require 'api_wrapper/api_manager'
require 'api_wrapper/cache/cache_store'
require 'api_wrapper/cache/cache_policy'

RSpec.describe ApiWrapper::ApiManager do
  let(:api_configuration_path) { 'spec/fixtures/api_configuration.yml' }
  let(:cache_store) { ApiWrapper::Cache::CacheStore.new }
  let(:api_manager) { described_class.new(api_configuration_path, cache_store: cache_store) }

  describe '#initialize' do
    it 'loads API configuration from file' do
      expect(api_manager.endpoints).to include('endpoint1' => a_hash_including('path' => 'path/to/endpoint1'))
      expect(api_manager.base_url).to eq('https://api.example.com/')
    end

    it 'configures cache policy based on YAML settings' do
      cache_policy = api_manager.instance_variable_get(:@cache_policy)

      # Check no-cache configuration
      expect(cache_policy.use_cache?('path/to/endpoint1')).to be_falsey

      # Check custom TTL configuration
      expect(cache_policy.ttl_for('path/to/endpoint2')).to eq(600)
    end
  end

  describe '#fetch_data' do
    let(:endpoint_key) { 'endpoint2' }
    let(:response_body) { { 'status' => 'success' }.to_json }

    before do
      stub_request(:get, 'https://api.example.com/path/to/endpoint2')
        .to_return(status: 200, body: response_body, headers: {})
    end

    it 'fetches data from the API and caches it' do
      response = api_manager.fetch_data(endpoint_key)
      expect(JSON.parse(response.body)).to eq('status' => 'success')

      # Verify that the data was cached
      cached_data = cache_store.read('path/to/endpoint2')
      expect(JSON.parse(cached_data)).to eq('status' => 'success')
    end

    it 'raises an error if the endpoint key is invalid' do
      expect do
        api_manager.fetch_data('invalid_endpoint')
      end.to raise_error(ArgumentError, 'Invalid endpoint key: invalid_endpoint')
    end

    context 'when force_refresh is true' do
      it 'bypasses the cache and fetches fresh data' do
        # Pre-cache some data
        cache_store.write('path/to/endpoint2', response_body, 300)

        # Fetch fresh data
        response = api_manager.fetch_data(endpoint_key, force_refresh: true)
        expect(JSON.parse(response.body)).to eq('status' => 'success')

        # Ensure the cache is updated with fresh data
        cached_data = cache_store.read('path/to/endpoint2')
        expect(JSON.parse(cached_data)).to eq('status' => 'success')
      end
    end
  end
end
