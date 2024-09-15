# frozen_string_literal: true

require 'spec_helper'
require 'api_wrapper/cache/cache_policy'
require 'api_wrapper/cache/cache_store'
require 'faraday'

RSpec.describe ApiWrapper::Cache::CachePolicy do
  let(:cache_store) { ApiWrapper::Cache::CacheStore.new }
  let(:cache_policy) { described_class.new(cache_store) }

  before do
    cache_policy.add_no_cache_endpoint('/no-cache')
    cache_policy.add_custom_ttl('/custom-ttl', 600) # 10 minutes
  end

  describe '#use_cache?' do
    it 'returns true for endpoints that are not in the no-cache list' do
      expect(cache_policy.use_cache?('/some-endpoint')).to be(true)
    end

    it 'returns false for endpoints that are in the no-cache list' do
      expect(cache_policy.use_cache?('/no-cache')).to be(false)
    end
  end

  describe '#fetch' do
    it 'uses cache if available and not forced to refresh' do
      # Simulate a Faraday::Response object
      cached_response = Faraday::Response.new(body: 'cached data')
      cache_policy.fetch('/some-endpoint') { cached_response }
      result = cache_policy.fetch('/some-endpoint')
      expect(result.body).to eq('cached data')
    end

    it 'bypasses cache if force_refresh is true' do
      cached_response = Faraday::Response.new(body: 'cached data')
      cache_policy.fetch('/some-endpoint') { cached_response }
      fresh_response = Faraday::Response.new(body: 'fresh data')
      result = cache_policy.fetch('/some-endpoint', force_refresh: true) { fresh_response }
      expect(result.body).to eq('fresh data')
    end

    it 'uses custom TTL for specific endpoints' do
      fresh_response = Faraday::Response.new(body: 'data with custom ttl')
      cache_policy.fetch('/custom-ttl') { fresh_response }
      result = cache_policy.fetch('/custom-ttl')
      expect(result.body).to eq('data with custom ttl')
    end
  end
end
