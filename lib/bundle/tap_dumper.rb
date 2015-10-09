require "json"

module Bundle
  class TapDumper
    attr_reader :taps

    def initialize
      if Bundle.brew_installed?
        @taps = begin
          JSON.load(`brew tap-info --json=v1 --installed`) || []
        rescue
          []
        end
      else
        raise "Unable to list installed taps. Homebrew is not currently installed on your system."
      end
    end

    def to_s
      @taps.map do |tap|
        remote = ", '#{tap["remote"]}'" if tap["custom_remote"] && tap["remote"]
        "tap '#{tap["name"]}'#{remote}"
      end.join("\n")
    end
  end
end
