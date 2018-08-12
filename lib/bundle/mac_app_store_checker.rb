# frozen_string_literal: true

module Bundle
  module Checker
    class MacAppStoreChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :mac_app_store
      PACKAGE_TYPE_NAME = "App"

      def installed_and_up_to_date?(id)
        Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date? id
      end

      def select_checkable(entries)
        super(entries).map { |e| [e.options[:id], e.name] }
                      .to_h
      end

      def full_check(app_ids_with_names)
        app_ids_with_names.reject { |id, _name| installed_and_up_to_date? id }
                          .map { |_id, name| "App #{name} needs to be installed or updated." }
      end
    end
  end
end
