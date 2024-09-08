# frozen_string_literal: true

# Load Bundler's gem tasks (e.g., `rake build`, `rake install`, etc.)
require 'bundler/gem_tasks'

# Load RSpec's rake task to run the test suite using `rake spec`
require 'rspec/core/rake_task'

# Define the `spec` task to run RSpec tests
RSpec::Core::RakeTask.new(:spec)

# Load RuboCop's rake task to check for style guide violations using `rake rubocop`
require 'rubocop/rake_task'

# Define the `rubocop` task to run RuboCop linter
RuboCop::RakeTask.new

# Load Yard's rake task for generating documentation using `rake yard`
require 'yard'

# Define the `yard` task to generate documentation
YARD::Rake::YardocTask.new

# By default, run both the `spec` (tests) and `rubocop` (linter) tasks
task default: %i[spec rubocop]

# Usage:
# 1. `rake spec` - Runs the RSpec tests
# 2. `rake rubocop` - Runs RuboCop linter for code quality checks
# 3. `rake yard` - Generates Yard documentation (output in the `doc/` folder)
# 4. `rake` - Runs both the tests and RuboCop checks (default task)
