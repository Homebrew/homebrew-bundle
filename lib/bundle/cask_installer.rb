module Bundle
  class CaskInstaller
    def self.install(name, options = {})
      if installed_casks.include? name
        if cask_up_to_date?(name)
          puts "Skipping install of #{name} cask. It is already installed." if ARGV.verbose?
          return true
        else
          puts "Cask #{name} is outdated." if ARGV.verbose?
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

    def self.cask_up_to_date?(name)
      # `brew cask info` outputs `Not installed` when a cask's version has been
      # updated and old one was installed before. It does this for never
      # installed casks, too. So this method cannot differentiate between an
      # outdated cask and a not installed cask. When the CLI output of `brew
      # cask` changes, this has to be updated, too.
      `brew cask info #{name}`.index('Not installed').nil?
    end
  end
end
