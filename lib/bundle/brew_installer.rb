module Bundle
  class BrewInstaller
    def self.reset!
      @installed_formulae = nil
      @outdated_formulae = nil
      @pinned_formulae = nil
    end

    def self.install(name, options = {})
      new(name, options).run
    end

    def initialize(name, options = {})
      @full_name = name
      @name = name.split("/").last
      @args = options.fetch(:args, []).map { |arg| "--#{arg}" }
      @conflicts_with_arg = options.fetch(:conflicts_with, [])
      @restart_service = options[:restart_service]
      @start_service = options[:start_service]
      @changed = nil
    end

    def run
      install_result = install_change_state!
      service_change_state! if install_result != :failed
      install_result
    end

    def install_change_state!
      return false unless resolve_conflicts!
      if installed?
        return :skipped if ARGV.include?("--no-upgrade")
        upgrade!
      else
        install!
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

    def service_change_state!
      if restart_service_needed?
        puts "Restarting #{@name} service." if ARGV.verbose?
        BrewServices.restart(@full_name)
      else
        true
      end
    end

    def self.formula_installed_and_up_to_date?(formula)
      return false unless formula_installed?(formula)
      return true if ARGV.include?("--no-upgrade")
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
      @outdated_formulae ||= Bundle::BrewDumper.formulae.map { |f| f[:name] if f[:outdated?] }.compact
    end

    def self.pinned_formulae
      @pinned_formulae ||= Bundle::BrewDumper.formulae.map { |f| f[:name] if f[:pinned?] }.compact
    end

    private

    def installed?
      BrewInstaller.formula_installed?(@name)
    end

    def upgradable?
      BrewInstaller.formula_upgradable?(@name)
    end

    def conflicts_with
      @conflicts_with ||= begin
        conflicts_with = Set.new
        conflicts_with += @conflicts_with_arg

        if (formula_info = Bundle::BrewDumper.formula_info(@full_name))
          if (formula_conflicts_with = formula_info[:conflicts_with])
            conflicts_with += formula_conflicts_with
          end
        end

        conflicts_with.to_a
      end
    end

    def resolve_conflicts!
      conflicts_with.each do |conflict|
        next unless BrewInstaller.formula_installed?(conflict)
        if ARGV.verbose?
          puts <<-EOS.undent
              Unlinking #{conflict} formula.
              It is currently installed and conflicts with #{@name}.
          EOS
        end
        return false unless Bundle.system("brew", "unlink", conflict)
        if @restart_service
          puts "Stopping #{conflict} service (if it is running)." if ARGV.verbose?
          BrewServices.stop(conflict)
        end
      end

      true
    end

    def install!
      puts "Installing #{@name} formula. It is not currently installed." if ARGV.verbose?
      unless Bundle.system("brew", "install", @full_name, *@args)
        @changed = nil
        return :failed
      end

      BrewInstaller.installed_formulae << @name
      @changed = true
      :success
    end

    def upgrade!
      unless upgradable?
        puts "Skipping install of #{@name} formula. It is already up-to-date." if ARGV.verbose?
        @changed = nil
        return :skipped
      end

      puts "Upgrading #{@name} formula. It is installed but not up-to-date." if ARGV.verbose?
      unless Bundle.system("brew", "upgrade", @name)
        @changed = nil
        return :failed
      end

      @changed = true
      :success
    end
  end
end
