module Bundle
  class MacAppStoreInstaller
    def self.install(name, id)
      unless Bundle.mas_installed?
        puts "Installing mas. It is not currently installed." if ARGV.verbose?
        Bundle.system "brew", "install", "mas"
        unless Bundle.mas_installed?
          raise "Unable to install #{name} app. mas installation failed."
        end
      end

      if installed_app_ids.include? id
        puts "Skipping install of #{name} app. It is already installed." if ARGV.verbose?
        return true
      end

      puts "Installing #{name} app. It is not currently installed." if ARGV.verbose?
      if (success = Bundle.system "mas", "install", "#{id}")
        installed_app_ids << id
      end

      success
    end

    def self.installed_app_ids
      @installed_app_ids ||= Bundle::MacAppStoreDumper.app_ids
    end
  end
end
