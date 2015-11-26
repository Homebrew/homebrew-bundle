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

RSpec.configure do |_config|
end


# Stub out the inclusion of Homebrew's code.
LIBS_TO_SKIP = ["cmd/info", "tap"]

module Kernel
  alias :old_require :require
  def require(path)
    old_require(path) unless LIBS_TO_SKIP.include?(path)
  end
end

module Homebrew
  def self.formulae_json
    []
  end
end

module Tap
  def self.map
    []
  end
end
