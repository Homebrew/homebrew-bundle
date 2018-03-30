# frozen_string_literal: true

module Bundle
  module MacAppStoreChecker
    module_function

    def ok?(id)
      Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date? id
    end

    def exit_early_check(app_ids)
      last_checked = ""
      work_to_be_done = app_ids.any? do |f|
          last_checked = f
          !ok?(f)
        end
      if work_to_be_done
        Bundle::Checker.action_required_for(last_checked)
      else
        Bundle::Checker::NO_ACTION
      end
    end

    def full_check(app_ids)
     actionable = app_ids.reject { |id, _name| ok? id }
     actionable.map { |_id, name| "App #{name} needs to be installed or updated." }
   end

   def find_actionable(entries)
     requested_app_ids = entries.select { |e| e.type == :mac_app_store }.map { |e| [e.options[:id], e.name] }.to_h

     if Bundle::Checker.exit_on_first_error?
       exit_early_check requested_app_ids
     else
       full_check requested_app_ids
     end
   end
  end
end
