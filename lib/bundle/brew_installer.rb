# frozen_string_literal: true

module Bundle
  class BrewInstaller
    def self.reset!
      @installed_formulae = nil
      @outdated_formulae = nil
      @pinned_formulae = nil
    end

    def self.preinstall(name, no_upgrade: false, verbose: false, **options)
      new(name, options).preinstall(no_upgrade: no_upgrade, verbose: verbose)
    end

    def self.install(name, preinstall: true, no_upgrade: false, verbose: false, **options)
      new(name, options).install(preinstall: preinstall, no_upgrade: no_upgrade, verbose: verbose)
    end

    def initialize(name, options = {})
      @full_name = name
      @name = name.split("/").last
      @args = options.fetch(:args, []).map { |arg| "--#{arg}" }
      @conflicts_with_arg = options.fetch(:conflicts_with, [])
      @restart_service = options[:restart_service]
      @start_service = options[:start_service]
      @link = options.fetch(:link, nil)
      @changed = nil
    end

    def preinstall(no_upgrade: false, verbose: false)
      if installed? && (no_upgrade || !upgradable?)
        puts "Skipping install of #{@name} formula. It is already installed." if verbose
        @changed = nil
        return false
      end

      true
    end

    def install(preinstall: true, no_upgrade: false, verbose: false)
      install_result = if preinstall
        install_change_state!(no_upgrade: no_upgrade, verbose: verbose)
      else
        true
      end

      if installed?
        service_change_state!(verbose: verbose) if install_result
        link_change_state!(verbose: verbose)
      end

      install_result
    end

    def install_change_state!(no_upgrade:, verbose:)
      return false unless resolve_conflicts!(verbose: verbose)

      if installed?
        upgrade!(verbose: verbose)
      else
        install!(verbose: verbose)
      end
    end

    def start_service?
      !@start_service.nil?
    end

    def restart_service?
      !@restart_service.nil?
    end

    def restart_service_needed?
      return false unless restart_service?

      # Restart if `restart_service: :always`, or if the formula was installed or upgraded
      @restart_service.to_s != "changed" || changed?
    end

    def changed?
      !@changed.nil?
    end

    def service_change_state!(verbose:)
      if restart_service_needed?
        puts "Restarting #{@name} service." if verbose
        BrewServices.restart(@full_name, verbose: verbose)
      else
        true
      end
    end

    def link_change_state!(verbose: false)
      case @link
      when true
        unless linked_and_keg_only?
          puts "Force-linking #{@name} formula." if verbose
          Bundle.system(HOMEBREW_BREW_FILE, "link", "--force", @name, verbose: verbose)
        end
      when false
        unless unlinked_and_not_keg_only?
          puts "Unlinking #{@name} formula." if verbose
          Bundle.system(HOMEBREW_BREW_FILE, "unlink", @name, verbose: verbose)
        end
      when nil
        if unlinked_and_not_keg_only?
          puts "Linking #{@name} formula." if verbose
          Bundle.system(HOMEBREW_BREW_FILE, "link", @name, verbose: verbose)
        elsif linked_and_keg_only?
          puts "Unlinking #{@name} formula." if verbose
          Bundle.system(HOMEBREW_BREW_FILE, "unlink", @name, verbose: verbose)
        end
      end
    end

    def self.formula_installed_and_up_to_date?(formula, no_upgrade: false)
      return false unless formula_installed?(formula)
      return true if no_upgrade

      !formula_upgradable?(formula)
    end

    def self.formula_in_array?(formula, array)
      return true if array.include?(formula)
      return true if array.include?(formula.split("/").last)

      old_names = Bundle::BrewDumper.formula_oldnames
      old_name = old_names[formula]
      old_name ||= old_names[formula.split("/").last]
      return true if old_name && array.include?(old_name)

      resolved_full_name = Bundle::BrewDumper.formula_aliases[formula]
      return false unless resolved_full_name
      return true if array.include?(resolved_full_name)
      return true if array.include?(resolved_full_name.split("/").last)

      false
    end

    def self.formula_installed?(formula)
      formula_in_array?(formula, installed_formulae)
    end

    def self.formula_linked_and_keg_only?(formula)
      formula_in_array?(formula, linked_and_keg_only_formulae)
    end

    def self.formula_unlinked_and_not_keg_only?(formula)
      formula_in_array?(formula, unlinked_and_not_keg_only_formulae)
    end

    def self.formula_upgradable?(formula)
      # Check local cache first and then authoratitive Homebrew source.
      formula_in_array?(formula, upgradable_formulae) && Formula[formula].outdated?
    end

    def self.installed_formulae
      @installed_formulae ||= Bundle::BrewDumper.formulae.map { |f| f[:name] }
    end

    def self.upgradable_formulae
      outdated_formulae - pinned_formulae
    end

    def self.outdated_formulae
      @outdated_formulae ||= formulae.map { |f| f[:name] if f[:outdated?] }.compact
    end

    def self.pinned_formulae
      @pinned_formulae ||= formulae.map { |f| f[:name] if f[:pinned?] }.compact
    end

    def self.linked_and_keg_only_formulae
      @linked_and_keg_only_formulae ||= formulae.map { |f| f[:name] if f[:link?] == true }.compact
    end

    def self.unlinked_and_not_keg_only_formulae
      @unlinked_and_not_keg_only_formulae ||= formulae.map { |f| f[:name] if f[:link?] == false }.compact
    end

    def self.formulae
      Bundle::BrewDumper.formulae
    end

    private

    def installed?
      BrewInstaller.formula_installed?(@name)
    end

    def linked_and_keg_only?
      BrewInstaller.formula_linked_and_keg_only?(@name)
    end

    def unlinked_and_not_keg_only?
      BrewInstaller.formula_unlinked_and_not_keg_only?(@name)
    end

    def upgradable?
      BrewInstaller.formula_upgradable?(@name)
    end

    def conflicts_with
      @conflicts_with ||= begin
        conflicts_with = Set.new
        conflicts_with += @conflicts_with_arg

        if (formula = Bundle::BrewDumper.formulae_by_full_name(@full_name)) &&
           (formula_conflicts_with = formula[:conflicts_with])
          conflicts_with += formula_conflicts_with
        end

        conflicts_with.to_a
      end
    end

    def resolve_conflicts!(verbose:)
      conflicts_with.each do |conflict|
        next unless BrewInstaller.formula_installed?(conflict)

        if verbose
          puts <<~EOS
            Unlinking #{conflict} formula.
            It is currently installed and conflicts with #{@name}.
          EOS
        end
        return false unless Bundle.system(HOMEBREW_BREW_FILE, "unlink", conflict, verbose: verbose)

        if restart_service?
          puts "Stopping #{conflict} service (if it is running)." if verbose
          BrewServices.stop(conflict, verbose: verbose)
        end
      end

      true
    end

    def install!(verbose:)
      puts "Installing #{@name} formula. It is not currently installed." if verbose
      unless Bundle.system(HOMEBREW_BREW_FILE, "install", "--formula", @full_name, *@args, verbose: verbose)
        @changed = nil
        return false
      end

      BrewInstaller.installed_formulae << @name
      @changed = true
      true
    end

    def upgrade!(verbose:)
      puts "Upgrading #{@name} formula. It is installed but not up-to-date." if verbose
      unless Bundle.system(HOMEBREW_BREW_FILE, "upgrade", "--formula", @name, verbose: verbose)
        @changed = nil
        return false
      end

      @changed = true
      true
    end
  end
end
