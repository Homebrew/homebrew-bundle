module Bundle
  class BrewInstaller
    def self.install(name, options = {})
      result = new(name, options).install_or_upgrade
      result = BrewServices.restart(name) if result && options[:restart_service]
      result
    end

    def initialize(name, options = {})
      if Bundle.brew_installed?
        @full_name = name
        @name = name.split("/").last
        @args = options.fetch(:args, []).map { |arg| "--#{arg}" }
      else
        raise "Unable to install #{name} formula. Homebrew is not currently installed on your system"
      end
    end

    def install_or_upgrade
      if installed?
        upgrade!
      else
        install!
      end
    end

    def self.upgradable_formulae
      outdated_formulae - pinned_formulae
    end

    private

    def self.installed_formulae
      @@installed_formulae ||= `brew list -1`.split("\n")
    end

    def self.outdated_formulae
      @@outdated_formulae ||= `brew outdated --quiet`.split("\n").map { |f| f.split("/").last }
    end

    def self.pinned_formulae
      @@pinned_formulae ||= `brew list --pinned`.split("\n")
    end

    def installed?
      BrewInstaller.installed_formulae.include?(@name)
    end

    def upgradable?
      BrewInstaller.upgradable_formulae.include?(@name)
    end

    def install!
      puts "Installing #{@name} formula. It is not currently installed." if ARGV.verbose?
      if (success = Bundle.system("brew", "install", @full_name, *@args))
        BrewInstaller.installed_formulae << @name
      end

      success
    end

    def upgrade!
      if upgradable?
        puts "Upgrading #{@name} formula. It is installed but not up-to-date." if ARGV.verbose?
        Bundle.system("brew", "upgrade", @name)
      else
        puts "Skipping install of #{@name} formula. It is already up-to-date." if ARGV.verbose?
        true
      end
    end
  end
end
