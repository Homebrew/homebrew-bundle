module Bundle
  module CaskDumper
    module_function

    def reset!
      @casks = nil
    end

    def casks
      @casks ||= if Bundle.cask_installed?
        `brew cask list -1 2>/dev/null`.split("\n").map { |cask| cask.chomp " (!)" }
      else
        []
      end
    end

    def dump(casks_required_by_formulae)
      [
        (casks & casks_required_by_formulae).map { |cask| "cask \"#{cask}\"" }.join("\n"),
        (casks - casks_required_by_formulae).map { |cask| "cask \"#{cask}\"" }.join("\n"),
      ]
    end
  end
end
