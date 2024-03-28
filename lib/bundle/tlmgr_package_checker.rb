# frozen_string_literal: true

module Bundle
  module Checker
    class TlmgrPackageChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :tlmgr
      PACKAGE_TYPE_NAME = "TeX Live Package"

      def failure_reason(package, no_upgrade:)
        "#{PACKAGE_TYPE_NAME} #{package} needs to be installed."
      end

      def installed_and_up_to_date?(package, no_upgrade: false)
        Bundle::TlmgrPackageInstaller.package_installed?(package)
      end
    end
  end
end
