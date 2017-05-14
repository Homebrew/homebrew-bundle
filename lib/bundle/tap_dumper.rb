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
        "tap \"#{tap["name"]}\"#{remote}"
      end.join("\n")
    end

    def tap_names
      taps.map { |tap| tap["name"] }
    end
  end
end
