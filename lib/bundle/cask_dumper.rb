module Bundle
  class CaskDumper
    def self.reset!
      @casks = nil
    end

    def self.casks
      @casks ||= `brew cask list -1 2>/dev/null`.split("\n").map { |cask| cask.chomp " (!)" }
    end

    def self.dump(casks_required_by_formulae)
      [
        (casks & casks_required_by_formulae).map { |cask| "cask '#{cask}'" }.join("\n"),
        (casks - casks_required_by_formulae).map { |cask| "cask '#{cask}'" }.join("\n"),
      ]
    end
  end
end
