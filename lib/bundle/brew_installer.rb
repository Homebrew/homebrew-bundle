module Bundle
  class BrewInstaller
    def self.reset!
      @installed_formulae = nil
      @outdated_formulae = nil
      @pinned_formulae = nil
    end

    def self.install(name, options = {})
      result = new(name, options).install_or_upgrade
      result = BrewServices.restart(name) if result && options[:restart_service]
      result
    end

    def initialize(name, options = {})
      @full_name = name
      @name = name.split("/").last
      @args = options.fetch(:args, []).map { |arg| "--#{arg}" }
    end

    def install_or_upgrade
      if installed?
        upgrade!
      else
        install!
      end
    end

    def self.formula_installed_and_up_to_date?(formula)
      formula_installed?(formula) && !formula_upgradable?(formula)
    end

    def self.formula_in_array?(formula, array)
      return true if array.include?(formula)
      return true if array.include?(formula.split("/").last)
      resolved_full_name = Bundle::BrewDumper.formula_aliases[formula]
      return false unless resolved_full_name
      return true if array.include?(resolved_full_name)
      return true if array.include?(resolved_full_name.split("/").last)
      false
    end

    private

    def self.formula_installed?(formula)
      formula_in_array?(formula, installed_formulae)
    end

    def self.formula_upgradable?(formula)
      formula_in_array?(formula, upgradable_formulae)
    end

    def self.installed_formulae
      @installed_formulae ||= Bundle::BrewDumper.formula_names
    end

    def self.upgradable_formulae
      outdated_formulae - pinned_formulae
    end

    def self.outdated_formulae
      @outdated_formulae ||= Bundle::BrewDumper.formulae.select { |f| f[:outdated?] }
    end

    def self.pinned_formulae
      @pinned_formulae ||= Bundle::BrewDumper.formulae.select { |f| f[:pinned?] }
    end

    def installed?
      BrewInstaller.formula_installed?(@name)
    end

    def upgradable?
      BrewInstaller.formula_upgradable?(@name)
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
