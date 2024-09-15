<!-- Note: This readme is simply moved from nse_data, so reflect on this doc for any minor mistakes. -->
# Caching Mechanism Usage and Customization

## Overview

The **ApiWrapper** gem includes a flexible caching mechanism to improve performance and reduce redundant API calls. This documentation provides an overview of how to use and customize the caching mechanism.

## Cache Policy

The `CachePolicy` class is responsible for managing caching behavior, including setting global TTLs, custom TTLs for specific endpoints, and controlling which endpoints should bypass the cache.

### Initializing CachePolicy

To use caching, you need to initialize the `CachePolicy` with a cache store and optional global TTL:

```ruby
require 'api_wrapper/cache/cache_policy'
require 'api_wrapper/cache/cache_store'

# Initialize the cache store (e.g., in-memory cache store)
cache_store = ApiWrapper::Cache::CacheStore.new

# Initialize the CachePolicy with the cache store and a global TTL of 300 seconds (5 minutes)
cache_policy = ApiWrapper::Cache::CachePolicy.new(cache_store, global_ttl: 300)
```

### Configuring Cache Policy
#### Adding No-Cache Endpoints
You can specify endpoints that should bypass the cache:
```ruby
# Add an endpoint to the no-cache list
cache_policy.add_no_cache_endpoint('/no-cache')
```

#### Adding Custom TTLs
You can define custom TTLs for specific endpoints:

```ruby
# Set a custom TTL of 600 seconds (10 minutes) for a specific endpoint
cache_policy.add_custom_ttl('/custom-ttl', ttl: 600)
```

#### Fetching Data with Cache
Use the fetch method to retrieve data with caching applied:

```ruby
# Fetch data for an endpoint with optional cache
data = cache_policy.fetch('/some-endpoint') do
  # The block should fetch fresh data if cache is not used or is stale
  # e.g., perform an API call or other data retrieval operation
  Faraday::Response.new(body: 'fresh data')
end
```
## Custom Cache Stores
You can extend the caching mechanism to support different types of cache stores. Implement a custom cache store by inheriting from the CacheStore base class and overriding the read and write methods.

### Example Custom Cache Store
```ruby
class CustomCacheStore < ApiWrapper::Cache::CacheStore
  def read(key)
    # Implement custom read logic
  end

  def write(key, value, ttl)
    # Implement custom write logic
  end
end
```
### Using a Custom Cache Store
To use a custom cache store, initialize CachePolicy with an instance of your custom cache store:

```ruby
# Initialize the custom cache store
custom_cache_store = CustomCacheStore.new

# Initialize CachePolicy with the custom cache store
cache_policy = ApiWrapper::Cache::CachePolicy.new(custom_cache_store, global_ttl: 300)
```