# frozen_string_literal: true

HOMEBREW_PREFIX = Pathname.new("/usr/local")
HOMEBREW_REPOSITORY = Pathname.new("/usr/local/Homebrew")
HOMEBREW_VERSION = "2.1.0"

module Homebrew
  module_function

  def args
    OpenStruct.new
  end
end
