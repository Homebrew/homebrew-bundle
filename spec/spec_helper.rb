# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
  minimum_coverage 100
end

PROJECT_ROOT ||= File.expand_path("..", __dir__)
STUB_PATH ||= File.expand_path(File.join(__FILE__, "..", "stub"))
$LOAD_PATH.unshift(STUB_PATH)

require "global"
require "bundle"

Dir.glob("#{PROJECT_ROOT}/lib/**/*.rb").each { |f| require f }

formatters = [SimpleCov::Formatter::HTMLFormatter]

# Coveralls in Azure Pipelines
if ENV["COVERALLS_REPO_TOKEN"] && ENV["TF_BUILD"]
  require "coveralls"

  formatters << Coveralls::SimpleCov::Formatter

  ENV["CI"] = "1"
  ENV["CI_NAME"] = "azure-pipelines"
  ENV["CI_BUILD_NUMBER"] = ENV["BUILD_BUILDID"]
  ENV["CI_BUILD_URL"] = "#{ENV["SYSTEM_TEAMFOUNDATIONSERVERURI"]}#{ENV["SYSTEM_TEAMPROJECT"]}/_build/results?buildId=#{ENV["BUILD_BUILDID"]}"
  ENV["CI_BRANCH"] = ENV["BUILD_SOURCEBRANCH"]
  ENV["CI_PULL_REQUEST"] = ENV["SYSTEM_PULLREQUEST_PULLREQUESTNUMBER"]

  require "simplecov-cobertura"
  formatters << SimpleCov::Formatter::CoberturaFormatter
end

STDERR.puts "Configured Simplecov formatters: #{formatters}"

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
end
