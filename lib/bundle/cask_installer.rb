module Bundle
  class CaskInstaller
    PERMITTED_OPTIONS = %w{caskroom appdir prefpanedir qlplugindir fontdir binarydir input_methoddir screen_saverdir}

    def self.install(name, options = {})
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

      if options.size
        @args = []
        options.each do |key, array|
          if PERMITTED_OPTIONS.include? key.to_s
            # puts "Installing #{name} with: #{options}"
            @args << "--#{key}=#{options[key]}"
            # puts "WARNING! Invalid cask option: #{key.to_s}"
          end
        end
      end

      if (success = Bundle.system("brew", "cask", "install", name, *@args))
        installed_casks << name
      end

      success
    end

    def self.installed_casks
      @@installed_casks ||= `brew cask list -1`.split("\n").map { |cask| cask.chomp " (!)" }
    end
  end
end
