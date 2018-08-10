# frozen_string_literal: true

module Bundle
  module Checker
    module_function

    NO_ACTION = [].freeze

    def action_required_for(formula)
      [formula]
    end

    def exit_on_first_error?
      !ARGV.include?("--verbose")
    end

    def exit_early_check(packages)
      last_checked = ""
      work_to_be_done = packages.any? do |pkg|
        last_checked = pkg
        yield pkg
      end
      if work_to_be_done
        Bundle::Checker.action_required_for(last_checked)
      else
        Bundle::Checker::NO_ACTION
      end
    end
  end
end
