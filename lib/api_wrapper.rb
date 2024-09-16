# frozen_string_literal: true

require_relative 'api_wrapper/version'
require_relative 'api_wrapper/api_manager'

# ApiWrapper provides a unified interface for managing API interactions and caching.
#
# It simplifies API management and caching with sensible defaults and customization options.
#
# Usage:
#   # Fetch data using default configuration
#   response = ApiWrapper.fetch_data('endpoint_key')
#   puts response.body
#
#   # Configure with custom settings
#   ApiWrapper.configure do |config|
#     config.api_configuration_path = 'custom/path/to/config.yml'
#     config.cache_store = CustomCacheStore.new
#   end
#   response = ApiWrapper.fetch_data('endpoint_key')
#   puts response.body
module ApiWrapper
  # Configuration class for managing settings
  class Configuration
    attr_accessor :api_configuration_path, :cache_store

    def initialize
      @api_configuration_path = default_api_configuration_path
      @cache_store = default_cache_store
    end

    private

    # Default API configuration path
    def default_api_configuration_path
      ENV['API_CONFIGURATION_PATH'] || File.join(Dir.pwd, 'config', 'api_endpoints.yml')
    end

    # Default cache store
    def default_cache_store
      cache_type = ENV['CACHE_STORE_TYPE'] || 'in_memory'
      case cache_type
      when 'redis'
        ApiWrapper::Cache::RedisCacheStore.new # TODO: implement RedisCacheStore later
      else
        ApiWrapper::Cache::CacheStore.new
      end
    end
  end

  class << self
    # Accesses the configuration instance, initializing if needed
    def configuration
      @configuration ||= Configuration.new
    end

    # Configures ApiWrapper with a block
    def configure
      raise ArgumentError, 'Configuration block required' unless block_given?

      yield(configuration)
      reset_api_manager!
    end

    # Returns the singleton ApiManager instance
    def api_manager
      @api_manager ||= begin
        config = configuration
        ApiManager.new(config.api_configuration_path, cache_store: config.cache_store)
      end
    end

    # Fetches data from the specified endpoint
    def fetch_data(endpoint_key, force_refresh: false)
      api_manager.fetch_data(endpoint_key, force_refresh: force_refresh)
    end

    # Resets the ApiManager instance
    def reset_api_manager!
      @api_manager = nil
    end
  end
end
