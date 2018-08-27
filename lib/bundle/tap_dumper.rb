# frozen_string_literal: true

require "json"

module Bundle
  module TapDumper
    module_function

    def reset!
      @taps = nil
    end

    def taps
      @taps ||= begin
        require "tap"
        Tap.map(&:to_hash)
      end
    end

    def dump
      taps.map do |tap|
        remote = ", \"#{tap["remote"]}\"" if tap["custom_remote"] && tap["remote"]
        pinned = ", pin: #{tap["pinned"]}" if tap["pinned"]
        "tap \"#{tap["name"]}\"#{remote}#{pinned}"
      end.sort.join("\n")
    end

    def tap_names
      taps.map { |tap| tap["name"] }
    end

    def pinned_tap_names
      taps.map { |tap| tap["name"] if tap["pinned"] }
    end
  end
end
