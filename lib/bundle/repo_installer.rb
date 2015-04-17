module Bundle
  class RepoInstaller
    def self.install(name)
      if Bundle.brew_installed?
        Bundle.system "brew", "tap", name
      else
        raise "Unable to tap #{name}. Homebrew is not currently installed on your system"
      end
    end
  end
end
