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

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
]
require "bundler"
require "rspec/support/object_formatter"

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = 200
  end

  # Never truncate output objects.
  RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

  config.around(:each) do |example|
    Bundler.with_clean_env { example.run }
  end
end
