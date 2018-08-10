# frozen_string_literal: true

module Bundle
  module MacAppStoreChecker
    module_function

    def installed_and_up_to_date?(id)
      Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date? id
    end

    def full_check(app_ids)
      app_ids.reject { |id, _name| installed_and_up_to_date? id }
             .map { |_id, name| "App #{name} needs to be installed or updated." }
    end

    def select_checkable(entries)
      entries.select { |e| e.type == :mac_app_store }
             .map { |e| [e.options[:id], e.name] }
             .to_h
    end

    def find_actionable(entries)
      requested = select_checkable entries

      if Bundle::Checker.exit_on_first_error?
        Bundle::Checker.exit_early_check(requested) { |pkg| !installed_and_up_to_date?(pkg) }
      else
        full_check requested
      end
    end
  end
end
