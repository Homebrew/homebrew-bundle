# frozen_string_literal: true

module Bundle
  module Checker
    class TapChecker < Bundle::Checker::Base
      PACKAGE_TYPE = :tap
      PACKAGE_TYPE_NAME = "Tap"

      def find_actionable(entries)
        requested_taps = format_checkable(entries)
        return [] if requested_taps.empty?

        current_taps = Bundle::TapDumper.tap_names
        (requested_taps - current_taps).map { |entry| "Tap #{entry} needs to be tapped." }
      end
    end
  end
end
