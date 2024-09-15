# frozen_string_literal: true

require 'yaml'
require_relative 'http_client/faraday_client'
require_relative 'cache/cache_policy'
require_relative 'cache/cache_store'

module ApiWrapper
  # ApiManager is responsible for managing API interactions, including fetching data from endpoints
  # and handling caching behavior.
  #
  # It supports configuration of caching policies, including specifying endpoints that should bypass
  # the cache and setting custom TTL (time-to-live) values for individual endpoints. The class
  # uses a Faraday client for making HTTP requests and integrates with a cache store for storing
  # and retrieving cached data.
  #
  # Usage:
  #   api_manager = ApiWrapper::ApiManager.new('path/to/api_configuration.yml')
  #
  #   response = api_manager.fetch_data('endpoint_key')
  #   puts response.body
  #
  # @attr_reader [Hash] endpoints The endpoints configuration loaded from the API configuration file.
  # @attr_reader [String] base_url The base URL for API requests.
  # @attr_reader [CachePolicy] cache_policy The cache policy used for caching data.
  # @attr_reader [FaradayClient] client The Faraday client used for making HTTP requests.
  class ApiManager
    # Initializes a new instance of the ApiManager class.
    #
    # @param api_configuration_path [String] Path to the API configuration file.
    # @param cache_store [CacheStore, RedisCacheStore, nil] The cache store to use for caching.
    # Defaults to in-memory cache if nil.
    def initialize(api_configuration_path, cache_store: nil)
      load_api_configuration(api_configuration_path)

      # Initialize cache policy
      @cache_policy = ApiWrapper::Cache::CachePolicy.new(cache_store || ApiWrapper::Cache::CacheStore.new)

      # Configure cache policy
      configure_cache_policy

      # Initialize Faraday client
      @client = ApiWrapper::HttpClient::FaradayClient.new(@base_url, @cache_policy)
    end

    # Fetches data from the specified API endpoint.
    #
    # @param endpoint_key [String] The key of the API endpoint to fetch data from.
    # @param force_refresh [Boolean] Whether to force refresh the data, bypassing the cache.
    # @return [Faraday::Response] The response object containing the fetched data.
    # @raise [ArgumentError] If the provided endpoint key is invalid.
    def fetch_data(endpoint_key, force_refresh: false)
      endpoint = @endpoints[endpoint_key]
      raise ArgumentError, "Invalid endpoint key: #{endpoint_key}" unless endpoint

      @cache_policy.fetch(endpoint['path'], force_refresh: force_refresh) do
        @client.get(endpoint['path'])
      end
    end

    attr_reader :endpoints, :base_url

    private

    # Loads the API configuration from the configuration file.
    #
    # @raise [RuntimeError] If the configuration file is missing or has syntax errors.
    def load_api_configuration(api_configuration_path)
      yaml_content = YAML.load_file(api_configuration_path)
      @endpoints = yaml_content['apis']
      @base_url = yaml_content['base_url']
    rescue Errno::ENOENT => e
      raise "Configuration file not found: #{e.message}"
    rescue Psych::SyntaxError => e
      raise "YAML syntax error: #{e.message}"
    end

    # Configures the cache policy with settings from the configuration file.
    def configure_cache_policy
      @endpoints.each_value do |endpoint|
        @cache_policy.add_no_cache_endpoint(endpoint['path']) if endpoint['no_cache']
        @cache_policy.add_custom_ttl(endpoint['path'], endpoint['ttl']) if endpoint['ttl']
      end
    end
  end
end
