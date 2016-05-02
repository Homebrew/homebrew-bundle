require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
  minimum_coverage 100
end

require "coveralls"
Coveralls.wear!

PROJECT_ROOT ||= File.expand_path("../..", __FILE__)
STUB_PATH ||= File.expand_path(File.join(__FILE__, "..", "stub"))
$:.unshift(STUB_PATH)

Dir.glob("#{PROJECT_ROOT}/lib/**/*.rb").each { |f| require f }

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

require "bundle"
require "bundler"

RSpec.configure do |config|
  config.around(:each) do |example|
    Bundler.with_clean_env { example.run }
  end
end

# Stub out the inclusion of Homebrew's code.
LIBS_TO_SKIP = ["formula", "tap"]

module Kernel
  alias_method :old_require, :require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end

class Formula
  def self.installed
    []
  end
end

module Tap
  def self.map
    []
  end
end
