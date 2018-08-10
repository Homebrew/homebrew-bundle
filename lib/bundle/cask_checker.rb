# frozen_string_literal: true

module Bundle
  module CaskChecker
    module_function

    def installed_and_up_to_date?(formula)
      Bundle::CaskInstaller.cask_installed_and_up_to_date? formula
    end

    def full_check(casks)
      actionable = casks.reject { |f| installed_and_up_to_date? f }
      actionable.map { |entry| "Cask #{entry} needs to be installed or updated." }
    end

    def find_actionable(entries)
      requested = entries.select { |e| e.type == :cask }.map(&:name)

      if Bundle::Checker.exit_on_first_error?
        Bundle::Checker.exit_early_check(requested){ |pkg| !installed_and_up_to_date?(pkg) }
      else
        full_check requested
      end
    end
  end
end
