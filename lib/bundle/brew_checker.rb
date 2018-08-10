# frozen_string_literal: true

module Bundle
  module BrewChecker
    module_function

    def installed_and_up_to_date?(formula)
      Bundle::BrewInstaller.formula_installed_and_up_to_date? formula
    end

    def full_check(formulae)
      actionable = formulae.reject { |f| installed_and_up_to_date? f }
      actionable.map { |entry| "Formula #{entry} needs to be installed or updated." }
    end

    def find_actionable(entries)
      requested_formulae = entries.select { |e| e.type == :brew }.map(&:name)

      if Bundle::Checker.exit_on_first_error?
        Bundle::Checker.exit_early_check(requested_formulae){ |pkg| !installed_and_up_to_date?(pkg) }
      else
        full_check requested_formulae
      end
    end
  end
end
