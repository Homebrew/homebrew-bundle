# frozen_string_literal: true

require "json"

module Bundle
  module TapDumper
    module_function

    def reset!
      @taps = nil
    end

    def dump
      taps.map do |tap|
        remote = if tap.custom_remote? && (tap_remote = tap.remote)
          ", \"#{tap_remote}\""
        end
        "tap \"#{tap.name}\"#{remote}"
      end.sort.uniq.join("\n")
    end

    def tap_names
      taps.map(&:name)
    end

    def taps
      @taps ||= begin
        require "tap"
        Tap.each.to_a
      end
    end
    private_class_method :taps
  end
end
