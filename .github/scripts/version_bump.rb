# frozen_string_literal: true

require 'fileutils'
require 'semantic'

VERSION_FILE = 'lib/api_wrapper/version.rb'

def read_current_version
  version_file = File.read(VERSION_FILE)
  version_file.match(/VERSION = ['"](.*)['"]/)[1]
end

def bump_version(type)
  new_version = calculate_new_version(type)
  update_version_file(new_version)
end

def calculate_new_version(type)
  current_version = Semantic::Version.new(read_current_version) # Replace with your current version logic

  new_version = case type
                when 'major'
                  current_version.major!
                when 'minor'
                  current_version.minor!
                else
                  current_version.patch!
                end

  new_version.to_s
end

def update_version_file(new_version)
  content = File.read(VERSION_FILE)
  new_content = content.gsub(/VERSION = ['"].*['"]/, "VERSION = '#{new_version}'")
  File.open(VERSION_FILE, 'w') { |file| file.write(new_content) }
end

def determine_bump_type
  labels = ENV['PR_LABELS'].to_s.split(',').map(&:strip)
  puts "PR_LABELS: #{labels}" # Debugging line to check labels

  skip_labels = %w[skip-version-bump ci]
  bump_labels = { 'bump-major' => 'major', 'bump-minor' => 'minor' }

  # Return 'skip' if any skip labels are present
  return 'skip' if (labels & skip_labels).any?

  # Return the corresponding bump type if any bump labels are present
  bump_labels.each do |label, bump_type|
    return bump_type if labels.include?(label)
  end

  # Default to patch bump
  'patch'
end

bump_type = determine_bump_type
if bump_type == 'skip'
  puts 'Skipping version bump due to label presence'
else
  bump_version(bump_type)
  puts "Bumped version to #{read_current_version}"
end
