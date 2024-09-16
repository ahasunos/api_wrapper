# frozen_string_literal: true

module ApiWrapper
  module Cache
    # CacheStore class provides an in-memory caching mechanism.
    class CacheStore
      def initialize
        @store = {}
      end

      # Retrieves the cached data for the given key, or fetches fresh data if not cached or expired.
      #
      # @param key [String] The cache key.
      # @param ttl [Integer] The time-to-live in seconds.
      # @yield Fetches fresh data if cache is expired or not present.
      # @return [Object] The cached data or the result of the block if not cached or expired.
      def fetch(key, ttl)
        if cached?(key, ttl)
          @store[key][:data]
        else
          fresh_data = yield
          store(key, fresh_data, ttl)
          fresh_data
        end
      end

      # Reads data from the cache.
      #
      # @param key [String] The cache key.
      # @return [Object, nil] The cached data, or nil if not present.
      def read(key)
        cached?(key) ? @store[key][:data] : nil
      end

      # Writes data to the cache with an expiration time.
      #
      # @param key [String] The cache key.
      # @param data [Object] The data to cache.
      # @param ttl [Integer] The time-to-live in seconds.
      def write(key, data, ttl)
        store(key, data, ttl)
      end

      # Deletes data from the cache.
      #
      # @param key [String] The cache key.
      def delete(key)
        @store.delete(key)
      end

      private

      # Checks if the data for the given key is cached and not expired.
      #
      # @param key [String] The cache key.
      # @param ttl [Integer] The time-to-live in seconds.
      # @return [Boolean] Whether the data is cached and valid.
      def cached?(key, ttl = nil)
        return false unless @store.key?(key)

        !expired?(key, ttl)
      end

      # Checks if the cached data for the given key has expired.
      #
      # @param key [String] The cache key.
      # @param ttl [Integer] The time-to-live in seconds.
      # @return [Boolean] Whether the cached data has expired.
      def expired?(key, ttl)
        stored_time = @store[key][:timestamp]
        ttl && (Time.now - stored_time) >= ttl
      end

      # Stores the data in the cache.
      #
      # @param key [String] The cache key.
      # @param data [Object] The data to cache.
      # @param ttl [Integer] The time-to-live in seconds.
      def store(key, data, ttl)
        @store[key] = { data:, timestamp: Time.now, ttl: }
      end
    end
  end
end
