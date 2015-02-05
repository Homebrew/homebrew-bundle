module Brewdler
  class CaskInstaller
    def self.install(name)
      if Brewdler.cask_installed?
        Brewdler.system "brew", "cask", "install", name
      else
        raise "Unable to install #{name}. Homebrew-cask is not currently installed on your system"
      end
    end
  end
end
