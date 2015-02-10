module Brewdler
  class CaskDumper
    attr_reader :casks

    def initialize
      if Brewdler.cask_installed?
        @casks = `brew cask list`.split
      else
        @casks = []
      end
    end

    def to_s
      @casks.map { |cask| "cask '#{cask}'"}.join("\n")
    end
  end
end
