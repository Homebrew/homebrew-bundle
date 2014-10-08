module Brewdler
  class CaskInstaller
    def self.install(name)
      if system 'brew cask > /dev/null'
        `brew cask install #{name}`
      else
        raise "Unable to install #{name}. Homebrew-cask is not currently installed on your system"
      end
    end
  end
end
