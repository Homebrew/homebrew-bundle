# frozen_string_literal: true

def macos?
  RUBY_PLATFORM[/darwin/]
end

def linux?
  RUBY_PLATFORM[/linux/]
end

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
  if macos?
    minimum_coverage 100
  else
    minimum_coverage 98
  end
end

PROJECT_ROOT ||= File.expand_path("..", __dir__)
STUB_PATH ||= File.expand_path(File.join(__FILE__, "..", "stub"))
$LOAD_PATH.unshift(STUB_PATH)

require "object"
require "os"
require "global"
require "bundle"

Dir.glob("#{PROJECT_ROOT}/lib/**/*.rb").each do |file|
  next if file.include?("/extend/os/")

  require file
end

formatters = [SimpleCov::Formatter::HTMLFormatter]

if macos? && ENV["COVERALLS_REPO_TOKEN"]
  require "coveralls"

  formatters << Coveralls::SimpleCov::Formatter

  ENV["CI"] = "1"
  ENV["CI_NAME"] = "github-actions"
  ENV["CI_BUILD_NUMBER"] = ENV["RUNNER_TRACKING_ID"]
  ENV["CI_BRANCH"] = ENV["GITHUB_REF"]
  # TODO: fill out values when more env vars available.
  # ENV["CI_BUILD_URL"] =
  # ENV["CI_PULL_REQUEST"] = ENV["SYSTEM_PULLREQUEST_PULLREQUESTNUMBER"]
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)

require "bundler"
require "rspec/support/object_formatter"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = 200
  end

  # Never truncate output objects.
  RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

  config.around do |example|
    Bundler.with_clean_env { example.run }
  end

  config.before(:each, :needs_linux) do
    skip "Not on Linux." unless linux?
  end

  config.before(:each, :needs_macos) do
    skip "Not on macOS." unless macos?
  end
end
