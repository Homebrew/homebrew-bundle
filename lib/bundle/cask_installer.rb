module Bundle
  class CaskInstaller
    def self.install(name)
      if Bundle.cask_installed?
        Bundle.system "brew", "cask", "install", name
      else
        raise "Unable to install #{name}. Homebrew-cask is not currently installed on your system"
      end
    end
  end
end
