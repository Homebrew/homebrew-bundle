module Brewdler
  class BrewInstaller
    def self.install(name)
      `brew install #{name}`
    end
  end
end
