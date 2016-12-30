module Bundle
  module MacAppStoreInstaller
    module_function

    def install(name, id)
      unless Bundle.mas_installed?
        puts "Installing mas. It is not currently installed." if ARGV.verbose?
        Bundle.system "brew", "install", "mas"
        unless Bundle.mas_installed?
          raise "Unable to install #{name} app. mas installation failed."
        end
      end

      unless Bundle.mas_signedin?
        puts "Not signed in to Mac App Store." if ARGV.verbose?
        Bundle.system "mas", "signin", "--dialog", ""
        unless Bundle.mas_signedin?
          raise "Unable to install #{name} app. mas not signed in to Mac App Store."
        end
      end

      if installed_app_ids.include? id
        puts "Skipping install of #{name} app. It is already installed." if ARGV.verbose?
        return :skipped
      end

      puts "Installing #{name} app. It is not currently installed." if ARGV.verbose?

      return :failed unless Bundle.system "mas", "install", id.to_s

      installed_app_ids << id
      :success
    end

    def installed_app_ids
      @installed_app_ids ||= Bundle::MacAppStoreDumper.app_ids
    end
  end
end
