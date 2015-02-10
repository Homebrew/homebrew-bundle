module Brewdler
  class RepoDumper
    attr_reader :repos

    def initialize
      if Brewdler.brew_installed?
        @repos = `brew tap`.split
      else
        raise "Unable to list installed taps. Homebrew is not currently installed on your system."
      end
    end

    def to_s
      @repos.map { |tap| "tap '#{tap}'"}.join("\n")
    end
  end
end
