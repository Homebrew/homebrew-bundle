require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter
]

require 'bundle'

RSpec.configure do |config|

end
