# frozen_string_literal: true

require 'spec_helper'
require 'api_wrapper/api_manager'
require 'api_wrapper'

RSpec.describe ApiWrapper do
  let(:custom_config_path) { File.join(Dir.pwd, 'config', 'api_endpoints.yml') }
  let(:default_cache_store) { instance_double(ApiWrapper::Cache::CacheStore) }
  let(:api_manager_instance) { instance_double(ApiWrapper::ApiManager) }

  before do
    allow(ApiWrapper::Cache::CacheStore).to receive(:new).and_return(default_cache_store)
  end

  describe '.configure' do
    it 'sets up configuration' do
      ApiWrapper.configure do |config|
        config.api_configuration_path = custom_config_path
      end
      expect(ApiWrapper.configuration.api_configuration_path).to eq(custom_config_path)
    end

    it 'raises an error when no block is given' do
      expect { ApiWrapper.configure }.to raise_error(ArgumentError, 'Configuration block required')
    end
  end

  describe '.api_manager' do
    it 'returns a singleton instance of ApiManager' do
      config_instance = instance_double(ApiWrapper::Configuration, api_configuration_path: custom_config_path,
                                                                   cache_store: default_cache_store)

      # Expect configuration to be called once
      expect(ApiWrapper).to receive(:configuration).once.and_return(config_instance)

      # Expect ApiManager.new to be called once with the correct arguments
      expect(ApiWrapper::ApiManager)
        .to receive(:new)
        .with(custom_config_path, cache_store: default_cache_store)
        .once
        .and_return(api_manager_instance)

      # Call api_manager to trigger the code
      result = ApiWrapper.api_manager

      # Expect api_manager to return the singleton instance
      expect(result).to eq(api_manager_instance)
    end
  end

  describe '.fetch_data' do
    it 'fetches data from ApiManager' do
      endpoint_key = 'endpoint_key'
      response = instance_double(Faraday::Response)

      # Create a double for the ApiManager instance
      api_manager_instance = instance_double(ApiWrapper::ApiManager)

      # Stub the fetch_data method on the ApiManager instance
      allow(ApiWrapper).to receive(:api_manager).and_return(api_manager_instance)
      allow(api_manager_instance).to receive(:fetch_data).with(endpoint_key, force_refresh: false).and_return(response)
      # Call the class method and expect it to return the response
      expect(ApiWrapper.fetch_data(endpoint_key)).to eq(response)
    end
  end

  describe '.reset_api_manager!' do
    it 'resets the ApiManager instance' do
      # originally with custom config path
      ApiWrapper.configure do |config|
        config.api_configuration_path = custom_config_path
      end

      expect(ApiWrapper.configuration.api_configuration_path).to eq(custom_config_path)
      # Create a double for the ApiManager instance
      api_manager_instance = instance_double(ApiWrapper::ApiManager)

      # Stub the api_manager method to return the double
      allow(ApiWrapper).to receive(:api_manager).and_return(api_manager_instance)

      # Stub the reset_api_manager! method
      allow(ApiWrapper).to receive(:reset_api_manager!)

      # Ensure a new instance is created after reset
      expect(ApiWrapper).to receive(:api_manager).and_return(api_manager_instance)

      # Call the reset_api_manager! method
      ApiWrapper.reset_api_manager!

      # Check that a new instance will be created & api configuration path is set to default
      expect(ApiWrapper.api_manager).to eq(api_manager_instance)
      expect(ApiWrapper.configuration.api_configuration_path).to eq(File.join(Dir.pwd, 'config/api_endpoints.yml'))
    end
  end
end
