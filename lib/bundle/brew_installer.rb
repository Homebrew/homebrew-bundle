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
        raise "Unable to install #{name}. Homebrew is not currently installed on your system"
      end
    end

    def install_or_upgrade
      if installed?
        upgrade!
      else
        install!
      end
    end

    private

    def installed_formulae
      @@installed_formulae ||= `brew list -1`.split("\n")
    end

    def outdated_formulae
      @@outdated_formulae ||= `brew outdated --quiet`.split("\n").map { |f| f.split("/").last }
    end

    def pinned_formulae
      @@pinned_formulae ||= `brew list --pinned`.split("\n")
    end

    def installed?
      installed_formulae.include?(@name)
    end

    def upgradable?
      outdated_formulae.include?(@name) &&
        ! pinned_formulae.include?(@name)
    end

    def install!
      if (success = Bundle.system("brew", "install", @full_name, *@args))
        installed_formulae << @name
      end

      success
    end

    def upgrade!
      return Bundle.system("brew", "upgrade", @name) if upgradable?
      true
    end
  end
end
