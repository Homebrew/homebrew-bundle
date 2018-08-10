# frozen_string_literal: true

module Bundle
  module BrewChecker
    module_function

    def installed_and_up_to_date?(formula)
      Bundle::BrewInstaller.formula_installed_and_up_to_date? formula
    end

    def full_check(formulae)
      formulae.reject { |f| installed_and_up_to_date? f }
              .map { |entry| "Formula #{entry} needs to be installed or updated." }
    end

    def select_checkable(entries)
      entries.select { |e| e.type == :brew }
             .map(&:name)
    end

    def find_actionable(entries)
      requested = select_checkable entries

      if Bundle::Checker.exit_on_first_error?
        Bundle::Checker.exit_early_check(requested){ |pkg| !installed_and_up_to_date?(pkg) }
      else
        full_check requested
      end
    end
  end
end
