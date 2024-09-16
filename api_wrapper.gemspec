# frozen_string_literal: true

require_relative 'lib/api_wrapper/version'

Gem::Specification.new do |spec|
  spec.name = 'api_wrapper'
  spec.version = ApiWrapper::VERSION
  spec.authors = ['Sonu Saha']
  spec.email = ['ahasunos@gmail.com']

  spec.summary = 'A Ruby gem to simplify API interactions'
  spec.description = 'ApiWrapper provides an easy-to-use interface for interacting with APIs in a configurable way'
  spec.homepage = 'https://github.com/ahasunos/api_wrapper'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ahasunos/api_wrapper'
  spec.metadata['changelog_uri'] = 'https://github.com/ahasunos/api_wrapper'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.11'
  spec.add_dependency 'faraday-http-cache', '~> 2.5', '>= 2.5.1'
end
