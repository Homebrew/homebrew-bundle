# frozen_string_literal: true

module Bundle
  module Skipper
    module_function

    def skip?(entry)
      Array(skipped_entries[entry.type]).include?(entry.name).tap do |skipped|
        puts Formatter.warning "Skipping #{entry.name}" if skipped
      end
    end

    private_class_method

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
