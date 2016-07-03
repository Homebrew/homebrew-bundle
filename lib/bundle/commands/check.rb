module Bundle::Commands
  class Check
    def self.reset!
      @dsl = nil
      Bundle::CaskDumper.reset!
      Bundle::BrewDumper.reset!
      Bundle::MacAppStoreDumper.reset!
      Bundle::TapDumper.reset!
    end

    def self.run
      if unsatisfied?
        puts "brew bundle can't satisfy your Brewfile's dependencies."
        puts "Install missing dependencies with `brew bundle install`."
        if ARGV.verbose?
          puts
          if taps_to_tap.any?
            puts "Taps to tap:"
            taps_to_tap.each {|tap| puts "- #{tap}" }
          end
          if casks_to_install.any?
            puts "Casks to install:"
            casks_to_install.each {|cask| puts "- #{cask.name}" }
          end
          if apps_to_install.any?
            puts "Apps to install:"
            apps_to_install.each {|app| puts "- #{app}" }
          end
          if formulae_to_install.any?
            puts "Formulae to install:"
            formulae_to_install.each {|formula| puts "- #{formula}" }
          end
        end
        exit 1
      else
        puts "The Brewfile's dependencies are satisfied."
      end
    end

    private

    def self.unsatisfied?
      any_taps_to_tap? || any_casks_to_install? || any_apps_to_install? || any_formulae_to_install?
    end

    def self.requested_casks
      @requested_casks ||= dsl.entries.select { |e| e.type == :cask }.map(&:name)
    end

    def self.current_casks
      @current_casks ||= Bundle::CaskDumper.casks
    end

    def self.casks_to_install
      @casks_to_install ||= requested_casks - current_casks
    end

    def self.any_casks_to_install?
      return false if requested_casks.empty?
      casks_to_install.any?
    end

    def self.requested_formulae
      @requested_formulae ||= dsl.entries.select { |e| e.type == :brew }.map(&:name)
    end

    def self.formulae_to_install
      requested_formulae.reject do |f|
        Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
      end
    end

    def self.any_formulae_to_install?
      formulae_to_install.any?
    end

    def self.requested_taps
      @requested_taps ||= dsl.entries.select { |e| e.type == :tap }.map(&:name)
    end

    def self.current_taps
      @current_taps ||= Bundle::TapDumper.tap_names
    end

    def self.taps_to_tap
      @taps_to_tap ||= requested_taps - current_taps
    end

    def self.any_taps_to_tap?
      return false if requested_taps.empty?
      taps_to_tap.any?
    end

    def self.requested_apps
      @requested_apps ||= dsl.entries.select { |e| e.type == :mac_app_store }.map {|e| e.options[:id] }
    end

    def self.current_apps
      @current_apps ||= Bundle::MacAppStoreDumper.app_ids
    end

    def self.apps_to_install
      @apps_to_install ||= requested_apps - current_apps
    end

    def self.any_apps_to_install?
      return false if requested_apps.empty?
      apps_to_install.any?
    end

    def self.dsl
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
    end
  end
end
