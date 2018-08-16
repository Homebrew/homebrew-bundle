# frozen_string_literal: true

module Bundle
  module Checker
    class BrewChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :brew
      PACKAGE_TYPE_NAME = "Formula"

      def installed_and_up_to_date?(formula)
        Bundle::BrewInstaller.formula_installed_and_up_to_date? formula
      end
    end
  end
end
