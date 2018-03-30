# frozen_string_literal: true

module Bundle
  module TapChecker
    module_function

    def find_actionable entries
      requested_taps = entries.select { |e| e.type == :tap }.map(&:name)
      return Bundle::Checker::NO_ACTION if requested_taps.empty?

      current_taps = Bundle::TapDumper.tap_names
      (requested_taps - current_taps).map { |entry| "Tap #{entry} needs to be tapped." }
    end
  end
end
