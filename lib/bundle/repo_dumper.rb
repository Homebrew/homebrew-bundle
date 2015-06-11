require "json"

module Bundle
  class RepoDumper
    attr_reader :repos

    def initialize
      if Bundle.brew_installed?
        @repos = JSON.load(`brew tap-info --json=v1 --installed`) || [] rescue []
      else
        raise "Unable to list installed taps. Homebrew is not currently installed on your system."
      end
    end

    def to_s
      @repos.map do |tap|
        remote = ", '#{tap["remote"]}'" if tap["custom_remote"]
        "tap '#{tap["name"]}'#{remote}"
      end.join("\n")
    end
  end
end
