# frozen_string_literal: true

module MacOS
  module_function

  def version
    :high_sierra
  end
end

module OS
  module_function

  def linux?
    RUBY_PLATFORM[/linux/]
  end
end
