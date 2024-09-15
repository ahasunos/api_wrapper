# frozen_string_literal: true

# spec/nse_data/http_client/faraday_client_spec.rb
require 'spec_helper'
require 'api_wrapper/http_client/faraday_client'
require 'api_wrapper/cache/cache_policy'
require 'api_wrapper/cache/cache_store'

RSpec.describe ApiWrapper::HttpClient::FaradayClient do
  let(:base_url) { 'https://www.nseindia.com/api/' }
  let(:cache_store) { ApiWrapper::Cache::CacheStore.new }
  let(:cache_policy) { ApiWrapper::Cache::CachePolicy.new(cache_store) }
  let(:client) { described_class.new(base_url, cache_policy) }

  describe '#get' do
    let(:endpoint) { 'special-preopen-listing' }
    let(:response_body) { { 'status' => 'success' }.to_json }

    context 'when a connection is successful and data is cached' do
      it 'returns the cached response if available' do
        # Cache the response
        cache_store.write(endpoint, response_body, 300)

        result = client.get(endpoint)
        expect(JSON.parse(result.body)).to eq('status' => 'success')
      end

      it 'fetches fresh data if cache is expired' do
        # Store data in cache but simulate it being expired by setting TTL to 0
        cache_store.write(endpoint, response_body, 0)

        stub_request(:get, "#{base_url}#{endpoint}")
          .with(
            headers: {
              'Accept' => 'application/json',
              'User-Agent' => 'ApiWrapperClient/1.0'
            }
          )
          .to_return(status: 200, body: response_body, headers: {})

        result = client.get(endpoint)
        expect(JSON.parse(result.body)).to eq('status' => 'success')
      end
    end

    context 'when a connection is successful but data is not cached' do
      it 'fetches fresh data and stores it in the cache' do
        # Ensure cache is empty
        expect(cache_store.read(endpoint)).to be_nil

        # Simulate a successful API response
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(
            headers: {
              'Accept' => 'application/json',
              'User-Agent' => 'ApiWrapperClient/1.0'
            }
          )
          .to_return(status: 200, body: response_body, headers: {})

        result = client.get(endpoint)
        expect(JSON.parse(result.body)).to eq('status' => 'success')

        # Check if the data is cached
        cached_data = cache_store.read(endpoint)
        expect(JSON.parse(cached_data)).to eq('status' => 'success')
      end
    end

    context 'when a connection failure occurs' do
      it 'raises a Faraday::Error' do
        endpoint = 'some-endpoint'

        # Simulate a Faraday connection failure
        allow_any_instance_of(Faraday::Connection).to receive(:get)
          .and_raise(Faraday::Error.new('Connection failed'))

        expect { client.get(endpoint) }.to raise_error(StandardError, 'Faraday error: Connection failed')
      end
    end

    context 'when force_refresh is true' do
      it 'bypasses the cache and fetches fresh data' do
        # Cache the response
        cache_store.write(endpoint, response_body, 300)

        # Simulate a successful API response
        stub_request(:get, "#{base_url}#{endpoint}")
          .with(
            headers: {
              'Accept' => 'application/json',
              'User-Agent' => 'ApiWrapperClient/1.0'
            }
          )
          .to_return(status: 200, body: response_body, headers: {})

        result = client.get(endpoint, force_refresh: true)
        expect(JSON.parse(result.body)).to eq('status' => 'success')

        # Ensure cache is still there but fresh data was fetched
        cached_data = cache_store.read(endpoint)
        expect(JSON.parse(cached_data)).to eq('status' => 'success')
      end
    end
  end
end
