# frozen_string_literal: true

module Bundle
  module Checker
    module_function

    NO_ACTION = []
    def ACTION_REQUIRED formula
      [formula]
    end

    def exit_on_first_error?
      !ARGV.include?("--verbose")
    end

  end
end
