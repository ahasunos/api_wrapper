# frozen_string_literal: true

module ApiWrapper
  module Cache
    # CachePolicy manages caching behavior, including cache storage and time-to-live (TTL) settings.
    #
    # It allows setting global TTLs, custom TTLs for specific endpoints, and controlling which
    # endpoints should not use the cache.
    #
    # @attr_reader [CacheStore] cache_store The cache store used for storing cached data.
    class CachePolicy
      attr_reader :cache_store

      # Initializes the CachePolicy with a cache store and global TTL.
      #
      # @param cache_store [CacheStore, RedisCacheStore] The cache store to use for caching.
      # @param global_ttl [Integer] The default TTL (in seconds) for caching.
      def initialize(cache_store, global_ttl = 300)
        @cache_store = cache_store
        @global_ttl = global_ttl
        @custom_ttls = {}
        @no_cache_endpoints = []
      end

      # Adds an endpoint that should bypass the cache.
      #
      # @param endpoint [String] The endpoint to exclude from caching.
      def add_no_cache_endpoint(endpoint)
        @no_cache_endpoints << endpoint
      end

      # Adds a custom TTL for a specific endpoint.
      #
      # @param endpoint [String] The endpoint to apply a custom TTL to.
      # @param ttl [Integer] The custom TTL value in seconds.
      def add_custom_ttl(endpoint, ttl = 300)
        @custom_ttls[endpoint] = ttl
      end

      # Returns the TTL for a specific endpoint. Defaults to the global TTL if no custom TTL is set.
      #
      # @param endpoint [String] The endpoint to fetch the TTL for.
      # @return [Integer] The TTL in seconds.
      def ttl_for(endpoint)
        @custom_ttls.fetch(endpoint, @global_ttl)
      end

      # Determines if caching should be used for the given endpoint.
      #
      # @param endpoint [String] The endpoint to check.
      # @return [Boolean] True if caching is enabled for the endpoint, false otherwise.
      def use_cache?(endpoint)
        !@no_cache_endpoints.include?(endpoint)
      end

      # Fetches the data for the given endpoint, using cache if applicable.
      #
      # @param endpoint [String] The endpoint to fetch data for.
      # @param force_refresh [Boolean] Whether to force refresh the data, bypassing the cache.
      # @yield The block that fetches fresh data if cache is not used or is stale.
      # @return [Object] The data fetched from cache or fresh data.
      def fetch(endpoint, force_refresh: false, &block)
        if force_refresh || !use_cache?(endpoint)
          fetch_fresh_data(endpoint, &block)
        else
          fetch_cached_or_fresh_data(endpoint, &block)
        end
      end

      private

      # Fetches fresh data and writes it to the cache if applicable.
      #
      # @param endpoint [String] The endpoint to fetch fresh data for.
      # @yield The block that fetches fresh data.
      # @return [Object] The fresh data.
      def fetch_fresh_data(endpoint)
        fresh_data = yield
        cache_fresh_data(endpoint, fresh_data)
        fresh_data
      end

      # Fetches cached data or fresh data if not available in the cache.
      #
      # @param endpoint [String] The endpoint to fetch data for.
      # @yield The block that fetches fresh data if cache is not used or is stale.
      # @return [Object] The cached or fresh data.
      def fetch_cached_or_fresh_data(endpoint, &block)
        cached_data = @cache_store.read(endpoint)
        if cached_data
          Faraday::Response.new(body: cached_data)
        else
          fetch_fresh_data(endpoint, &block)
        end
      end

      # Writes fresh data to the cache.
      #
      # @param endpoint [String] The endpoint for which to store the data.
      # @param fresh_data [Object] The data to be stored in the cache.
      def cache_fresh_data(endpoint, fresh_data)
        ttl = determine_ttl(endpoint)
        @cache_store.write(endpoint, fresh_data.body, ttl) if fresh_data.is_a?(Faraday::Response)
      end

      # Determines the TTL value for the given endpoint.
      #
      # @param endpoint [String] The endpoint to fetch the TTL for.
      # @return [Integer] The TTL value in seconds.
      def determine_ttl(endpoint)
        @custom_ttls.fetch(endpoint, @global_ttl)
      end
    end
  end
end
