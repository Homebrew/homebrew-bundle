module Brewdler
  class CaskInstaller
    def self.install(name)
      `brew cask install #{name}`
    end
  end
end
