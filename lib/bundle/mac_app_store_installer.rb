# frozen_string_literal: true

module Bundle
  module MacAppStoreInstaller
    module_function

    def reset!
      @installed_app_ids = nil
      @outdated_app_ids = nil
    end

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

      if app_id_installed?(id)
        if !ARGV.include?("--no-upgrade") && app_id_upgradable?(id)
          puts "Upgrading #{name} app. It is installed but not up-to-date." if ARGV.verbose?
          return :failed unless Bundle.system "mas", "upgrade", id.to_s
          return :success
        end
        return :skipped
      end

      puts "Installing #{name} app. It is not currently installed." if ARGV.verbose?

      return :failed unless Bundle.system "mas", "install", id.to_s

      installed_app_ids << id
      :success
    end

    def self.app_id_installed_and_up_to_date?(id)
      return false unless app_id_installed?(id)
      return true if ARGV.include?("--no-upgrade")
      !app_id_upgradable?(id)
    end

    def app_id_installed?(id)
      installed_app_ids.include? id.to_s
    end

    def app_id_upgradable?(id)
      outdated_app_ids.include? id.to_s
    end

    def installed_app_ids
      @installed_app_ids ||= Bundle::MacAppStoreDumper.app_ids
    end

    def outdated_app_ids
      @outdated_app_ids ||= if Bundle.mas_installed?
        `mas outdated 2>/dev/null`.split("\n").map do |app|
          app.split(" ", 2).first
        end
      else
        []
      end
    end
  end
end
