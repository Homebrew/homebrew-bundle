# frozen_string_literal: true

module Bundle
  module Skipper
    class << self
      def skip?(entry, silent: false)
        entry_type_skips = Array(skipped_entries[entry.type])
        return false if entry_type_skips.empty?

        # Check the name or ID particularly for Mac App Store entries where they
        # can have spaces in the names (and the `mas` output format changes on
        # occasion).
        entry_ids = [entry.name, entry.options[:id]&.to_s].compact
        return false if (entry_type_skips & entry_ids).empty?
        return true if silent

        puts Formatter.warning "Skipping #{entry.name}"
        true
      end
      alias generic_skip? skip?

      private

      def skipped_entries
        return @skipped_entries if @skipped_entries

        @skipped_entries = {}
        [:brew, :cask, :mas, :tap].each do |type|
          @skipped_entries[type] =
            ENV["HOMEBREW_BUNDLE_#{type.to_s.upcase}_SKIP"]&.split
        end
        @skipped_entries
      end
    end
  end
end

require "bundle/extend/os/skipper"
