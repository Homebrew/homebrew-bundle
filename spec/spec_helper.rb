require "simplecov"
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
  minimum_coverage 100
end

require "coveralls"
Coveralls.wear!

PROJECT_ROOT ||= File.expand_path('../..', __FILE__)
Dir.glob("#{PROJECT_ROOT}/lib/**/*.rb").each { |f| require f }

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

require "bundle"
require 'bundler'

RSpec.configure do |config|
  config.around(:each) do |example|
    Bundler.with_clean_env { example.run }
  end
end


# Stub out the inclusion of Homebrew's code.
LIBS_TO_SKIP = ["formula", "tap"]

module Kernel
  alias :old_require :require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end

module Formula
  def self.installed
    []
  end
end

module Tap
  def self.map
    []
  end
end
