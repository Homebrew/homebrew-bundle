module Bundle
  class CaskInstaller
    def self.install(name)
      unless Bundle.brew_installed?
        raise "Unable to install #{name}. Homebrew is not currently installed on your system"
      end

      unless Bundle.cask_installed?
        Bundle.system "brew", "install", "caskroom/cask/brew-cask"

        unless Bundle.cask_installed?
          raise "Unable to install #{name}. Homebrew-cask is not currently installed on your system"
        end
      end

      if installed_casks.include? name
        puts "Skip to install #{name}" if ARGV.verbose?
        return true
      end

      if (success = Bundle.system "brew", "cask", "install", name)
        installed_casks << name
      end

      success
    end

    def self.installed_casks
      @@installed_casks ||= `brew cask list -1`.split("\n").map { |cask| cask.chomp " (!)" }
    end
  end
end
