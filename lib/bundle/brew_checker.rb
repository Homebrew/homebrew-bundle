# frozen_string_literal: true

module Bundle
  module BrewChecker
    module_function

    def exit_early_check formulae
      last_checked = ""
      work_to_be_done = formulae.any? do |f|
          last_checked = f
          !Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
        end
      if work_to_be_done
        Bundle::Checker::ACTION_REQUIRED(last_checked)
      else
        Bundle::Checker::NO_ACTION
      end
    end

    def full_check formulae
     actionable = formulae.reject do |f|
       Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
     end
     actionable.map { |entry| "Formula #{entry} needs to be installed or updated." }
   end

   def find_actionable entries
     requested_formulae = entries.select { |e| e.type == :brew }.map(&:name)

     if Bundle::Checker::exit_on_first_error?
       exit_early_check requested_formulae
     else
       full_check requested_formulae
     end
   end

  end
end
