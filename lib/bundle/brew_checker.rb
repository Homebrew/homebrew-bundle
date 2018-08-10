# frozen_string_literal: true

module Bundle
  module BrewChecker
    module_function

    def installed_and_up_to_date?(formula)
      Bundle::BrewInstaller.formula_installed_and_up_to_date? formula
    end

    def exit_early_check(formulae)
      last_checked = ""
      work_to_be_done = formulae.any? do |f|
        last_checked = f
        !installed_and_up_to_date?(f)
      end
      if work_to_be_done
        Bundle::Checker.action_required_for(last_checked)
      else
        Bundle::Checker::NO_ACTION
      end
    end

    def full_check(formulae)
      actionable = formulae.reject { |f| installed_and_up_to_date? f }
      actionable.map { |entry| "Formula #{entry} needs to be installed or updated." }
    end

    def find_actionable(entries)
      requested_formulae = entries.select { |e| e.type == :brew }.map(&:name)

      if Bundle::Checker.exit_on_first_error?
        exit_early_check requested_formulae
      else
        full_check requested_formulae
      end
    end
  end
end
