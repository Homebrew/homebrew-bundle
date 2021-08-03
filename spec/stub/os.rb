# frozen_string_literal: true

module MacOS
  module CLT
    def self.version
      "1100.0.33.8"
    end
  end

  module Xcode
    def self.version
      "11.2"
    end
  end

  module_function

  def full_version
    "10.15.1"
  end

  def version
    OpenStruct.new to_sym: :catalina, prerelease?: false
  end
end

module OS
  module Linux
    def self.os_version
      "Unknown"
    end
  end

  module_function

  def linux?
    RUBY_PLATFORM[/linux/]
  end
end
