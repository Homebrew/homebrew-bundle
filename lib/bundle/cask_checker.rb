# frozen_string_literal: true

module Bundle
  module CaskChecker
    module_function

    def installed_and_up_to_date?(formula)
      Bundle::CaskInstaller.cask_installed_and_up_to_date? formula
    end

    def exit_early_check(casks)
      last_checked = ""
      work_to_be_done = casks.any? do |f|
        last_checked = f
        !installed_and_up_to_date?(f)
      end
      if work_to_be_done
        Bundle::Checker.action_required_for(last_checked)
      else
        Bundle::Checker::NO_ACTION
      end
    end

    def full_check(casks)
      actionable = casks.reject { |f| installed_and_up_to_date? f }
      actionable.map { |entry| "Cask #{entry} needs to be installed or updated." }
    end

    def find_actionable(entries)
      requested = entries.select { |e| e.type == :cask }.map(&:name)

      if Bundle::Checker.exit_on_first_error?
        exit_early_check requested
      else
        full_check requested
      end
    end
  end
end
