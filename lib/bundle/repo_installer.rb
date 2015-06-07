module Bundle
  class RepoInstaller
    def self.install(name, clone_target)
      unless Bundle.brew_installed?
        raise "Unable to tap #{name}. Homebrew is not currently installed on your system"
      end

      if clone_target
        Bundle.system "brew", "tap", name, clone_target
      else
        Bundle.system "brew", "tap", name
      end
    end
  end
end
