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
