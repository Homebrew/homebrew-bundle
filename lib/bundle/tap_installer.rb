module Bundle
  class TapInstaller
    def self.install(name, clone_target)
      unless Bundle.brew_installed?
        raise "Unable to install #{name} tap. Homebrew is not currently installed on your system"
      end

      if installed_taps.include? name
        puts "Skipping install of #{name} tap. It is already installed." if ARGV.verbose?
        return true
      end

      puts "Installing #{name} tap. It is not currently installed." if ARGV.verbose?
      if clone_target
        Bundle.system "brew", "tap", name, clone_target
      else
        Bundle.system "brew", "tap", name
      end
    end

    def self.installed_taps
      @@installed_taps ||= `brew tap`.split("\n")
    end
  end
end
