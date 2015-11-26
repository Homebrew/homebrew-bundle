require "json"

module Bundle
  class TapDumper
    def self.reset!
      @taps = nil
    end

    def self.taps
      @taps ||= begin
        require "tap"
        Tap.map(&:to_hash)
      end
    end

    def self.dump
      taps.map do |tap|
        remote = ", '#{tap["remote"]}'" if tap["custom_remote"] && tap["remote"]
        "tap '#{tap["name"]}'#{remote}"
      end.join("\n")
    end

    def self.tap_names
      taps.map { |tap| tap["name"] }
    end
  end
end
