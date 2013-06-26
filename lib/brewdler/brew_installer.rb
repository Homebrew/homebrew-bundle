module Brewdler
  class BrewInstaller
    def self.install(name)
      if system 'brew info'
        `brew install #{name}`
      else
        raise "Unable to install #{name}. Homebrew is not currently installed on your system."
      end
    end
  end
end
