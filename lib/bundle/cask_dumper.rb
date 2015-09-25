module Bundle
  class CaskDumper
    attr_reader :casks

    def initialize
      if Bundle.cask_installed?
        @casks = `brew cask list -1 2>/dev/null`.split("\n").map { |cask| cask.chomp " (!)" }
      else
        @casks = []
      end
    end

    def dump_to_string(formula_requirements)
      [
        (@casks & formula_requirements).map { |cask| "cask '#{cask}'"}.join("\n"),
        (@casks - formula_requirements).map { |cask| "cask '#{cask}'"}.join("\n")
      ]
    end
  end
end
