module Bundle
  class CaskDumper
    attr_reader :casks

    def initialize
      if Bundle.cask_installed?
        @casks = `brew cask list -1`.split("\n").map { |cask| cask.chomp " (!)" }
      else
        @casks = []
      end
    end

    def to_s
      @casks.map { |cask| "cask '#{cask}'"}.join("\n")
    end
  end
end
