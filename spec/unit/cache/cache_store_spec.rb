# frozen_string_literal: true

require 'spec_helper'
require 'api_wrapper/cache/cache_store'

RSpec.describe ApiWrapper::Cache::CacheStore do
  let(:cache_store) { described_class.new }
  let(:key) { 'test_key' }
  let(:data) { 'test_data' }
  let(:ttl) { 5 } # 5 seconds TTL

  describe '#fetch' do
    context 'when data is not cached' do
      it 'fetches new data and stores it' do
        result = cache_store.fetch(key, ttl) { data }
        expect(result).to eq(data)
        expect(cache_store.read(key)).to eq(data)
      end
    end

    context 'when data is cached' do
      before do
        cache_store.fetch(key, ttl) { data }
      end

      it 'returns cached data within TTL' do
        result = cache_store.fetch(key, ttl) { 'new_data' }
        expect(result).to eq(data)
      end

      it 'returns fresh data after TTL expires' do
        # Use Timecop to freeze time for precise TTL testing
        require 'timecop'
        Timecop.travel(Time.now + ttl + 1) do
          result = cache_store.fetch(key, ttl) { 'new_data' }
          expect(result).to eq('new_data')
        end
      end
    end
  end

  describe '#read' do
    context 'when data is cached' do
      before do
        cache_store.fetch(key, ttl) { data }
      end

      it 'returns the cached data' do
        expect(cache_store.read(key)).to eq(data)
      end
    end

    context 'when data is not cached' do
      it 'returns nil' do
        expect(cache_store.read(key)).to be_nil
      end
    end
  end

  describe '#write' do
    it 'stores data in the cache' do
      cache_store.write(key, data, ttl)
      expect(cache_store.read(key)).to eq(data)
    end
  end

  describe '#delete' do
    context 'when data is cached' do
      before do
        cache_store.write(key, data, ttl)
      end

      it 'removes the data from the cache' do
        cache_store.delete(key)
        expect(cache_store.read(key)).to be_nil
      end
    end
  end
end
