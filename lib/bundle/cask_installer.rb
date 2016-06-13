module Bundle
  class CaskInstaller
    def self.install(name, options = {})
      if installed_casks.include? name
        # `brew cask info` outputs `Not installed` when a cask's version has
        # been updated and old one was installed before. When the CLI output
        # changes, this has to be updated, too.
        outdated = `brew cask info #{name}`.index('Not installed')

        if outdated
          puts "Cask #{name} is outdated." if ARGV.verbose?
        else
          puts "Skipping install of #{name} cask. It is already installed." if ARGV.verbose?
          return true
        end
      elsif ARGV.verbose?
        puts "Cask #{name} is not installed."
      end

      args = options.fetch(:args, []).map { |k, v| "--#{k}=#{v}" }

      puts "Installing #{name} cask." if ARGV.verbose?
      if (success = Bundle.system "brew", "cask", "install", name, *args)
        installed_casks << name
      end

      success
    end

    def self.installed_casks
      @installed_casks ||= Bundle::CaskDumper.casks
    end
  end
end
