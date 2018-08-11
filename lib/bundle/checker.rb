# frozen_string_literal: true

module Bundle
  module Checker
    module_function

    NO_ACTION = [].freeze

    def action_required_for(formula)
      [formula]
    end

    def exit_early_check(packages)
      work_to_be_done = packages.find do |pkg|
        yield pkg
      end
      if work_to_be_done
        Bundle::Checker.action_required_for(work_to_be_done)
      else
        Bundle::Checker::NO_ACTION
      end
    end

    def exit_on_first_error?
      !ARGV.include?("--verbose")
    end

    def output_errors?
      ARGV.include?("--verbose")
    end
  end
end
