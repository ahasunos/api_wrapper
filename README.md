## ApiWrapper
[![Gem Version](https://badge.fury.io/rb/api_wrapper.svg)](https://badge.fury.io/rb/api_wrapper)
![Ruby Test Status](https://github.com/ahasunos/api_wrapper/actions/workflows/test.yml/badge.svg)
![Lint Status](https://github.com/ahasunos/api_wrapper/actions/workflows/lint.yml/badge.svg)
![Bundler Audit Status](https://github.com/ahasunos/api_wrapper/actions/workflows/bundler_audit.yml/badge.svg)

`ApiWrapper` is a Ruby gem that offers an easy and flexible way to handle API interactions.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Custom Configuration](#custom-configuration)
  - [Resetting the API Manager](#resetting-the-api-manager)
- [Configuration](#configuration)
  - [API Configuration File](#api-configuration-file)
- [Key Methods](#key-methods)
- [Development](#development)
  - [Running Tests](#running-tests)
  - [Code Style and Linting](#code-style-and-linting)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

Add this to your Gemfile:


```ruby
gem 'api_wrapper'
```

Then run

```ruby
bundle install
```

## Usage

### Basic Usage
By default, ApiWrapper looks for an API configuration file at `config/api_endpoints.yml` (see [API Configuration File](#api-configuration-file)) in your root directory of your application and uses in-memory caching. You can fetch data from an API endpoint like this:

```ruby
require 'api_wrapper'

# Fetch data from an API endpoint using the default settings
response = ApiWrapper.fetch_data('endpoint_key')
puts response.body
```

### Custom Configuration
You can customize the API configuration path and cache store by configuring ApiWrapper:

```ruby
require 'api_wrapper'

# Configure ApiWrapper with custom settings
ApiWrapper.configure do |config|
  config.api_configuration_path = 'custom/path/to/api_configuration.yml'
  config.cache_store = CustomCacheStore.new # TODO: Update details on CustomCacheStore later
end

# Fetch data with the custom configuration
response = ApiWrapper.fetch_data('endpoint_key')
puts response.body
```

### Resetting the API Manager
If you change the configuration and want to reset the API manager, call:
```ruby
ApiWrapper.reset_api_manager!
```
This will create a new instance of ApiManager with the updated settings.

## Configuration
You can adjust two main settings:

1. **API Configuration Path**: This is the path to the YAML file that defines your API endpoints. By default, it’s set to config/api_endpoints.yml. You can also set it through the environment variable ENV['API_CONFIGURATION_PATH'].

2. **Cache Store**: This is where API responses are stored. By default, ApiWrapper uses an in-memory cache. You can customize this to use a different cache store, such as Redis. You can also set the cache type through ENV['CACHE_STORE_TYPE'].

### API Configuration File
Your configuration file (api_endpoints.yml) defines the base URL for the API and the available endpoints. Here’s an example:

```yaml
base_url: https://api.example.com/
apis:
  endpoint1:
    path: 'path/to/endpoint1'
    description: 'Endpoint 1 description'
    no_cache: true
  endpoint2:
    path: 'path/to/endpoint2'
    description: 'Endpoint 2 description'
    ttl: 600
```

- base_url: The base URL for all API requests.
- apis: A list of API endpoints.
    - path: The path to the API endpoint.
    - description: (Optional) The description about the endpoint
    - ttl: (Optional) The time (in seconds) that data should be cached.
    - no_cache: (Optional) Whether to bypass caching for this endpoint.

## Key Methods
- `ApiWrapper.fetch_data(endpoint_key, force_refresh: false)`: Fetches data from the specified API endpoint.
- `ApiWrapper.configure { |config| ... }`: Allows you to configure the gem with custom settings.
- `ApiWrapper.reset_api_manager!`: Resets the ApiManager instance, which will use any new settings.

## Development

To get started with contributing to **ApiWrapper**, follow these steps:

1. **Clone the repository**:

   First, clone the repository to your local machine and navigate to the project directory:

   ```bash
   git clone https://github.com/ahasunos/api_wrapper.git
   cd api_wrapper

2. **Install dependencies**:

   After navigating to the project directory, install the required gems using Bundler:

   ```bash
   bundle install
   ```

### Running Tests
The project uses RSpec for testing. Before submitting any changes, make sure to run the test suite to ensure that everything works as expected:

```bash
bundle exec rspec
```

### Code Style and Linting
To maintain consistent code quality and style, the project uses RuboCop for linting. Before submitting a pull request, ensure that your code adheres to the project's style guidelines by running RuboCop:

```bash
bundle exec rubocop
```

If RuboCop identifies any issues, it will provide suggestions for how to fix them.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ahasunos/api_wrapper. For major changes, please open an issue first to discuss what you would like to change.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NseData project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/ahasunos/api_wrapper/blob/master/CODE_OF_CONDUCT.md).
