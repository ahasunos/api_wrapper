# frozen_string_literal: true

module ApiWrapper
  module HttpClient
    # Base class for HTTP clients
    class BaseClient
      # Initializes a new instance of the BaseClient class.
      #
      # @param base_url [String] The base URL for the HTTP client.
      def initialize(base_url, cache_policy)
        @base_url = base_url
        @cache_policy = cache_policy
      end

      # Sends a GET request to the specified endpoint.
      #
      # @param endpoint [String] The endpoint to send the GET request to.
      # @raise [NotImplementedError] If the method is not implemented by subclasses.
      def get(endpoint)
        raise NotImplementedError, 'Subclasses must implement the get method'
      end

      # TODO: Other HTTP methods like post, put, delete can be added here if needed
    end
  end
end
