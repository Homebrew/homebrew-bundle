module Bundle
  module Commands
    module Check
      module_function

      def reset!
        @dsl = nil
        Bundle::CaskDumper.reset!
        Bundle::BrewDumper.reset!
        Bundle::MacAppStoreDumper.reset!
        Bundle::TapDumper.reset!
        Bundle::BrewServices.reset!
      end

      def run
        if any_taps_to_tap? ||
           any_casks_to_install? ||
           any_apps_to_install? ||
           any_formulae_to_install? ||
           any_formulae_to_start?
          puts "brew bundle can't satisfy your Brewfile's dependencies."
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end

      def any_casks_to_install?
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_casks = @dsl.entries.select { |e| e.type == :cask }.map(&:name)
        return false if requested_casks.empty?
        current_casks = Bundle::CaskDumper.casks
        (requested_casks - current_casks).any?
      end

      def any_formulae_to_install?
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
        requested_formulae.any? do |f|
          !Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
        end
      end

      def any_taps_to_tap?
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
        return false if requested_taps.empty?
        current_taps = Bundle::TapDumper.tap_names
        (requested_taps - current_taps).any?
      end

      def any_apps_to_install?
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_apps = @dsl.entries.select { |e| e.type == :mac_app_store }.map { |e| e.options[:id] }
        return false if requested_apps.empty?
        current_apps = Bundle::MacAppStoreDumper.app_ids
        (requested_apps - current_apps).any?
      end

      def any_formulae_to_start?
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        @dsl.entries.select { |e| e.type == :brew }.any? do |e|
          formula = Bundle::BrewInstaller.new(e.name, e.options)
          needs_to_start = formula.start_service? || formula.restart_service?
          next unless needs_to_start
          next if Bundle::BrewServices.started?(e.name)

          old_names = Bundle::BrewDumper.formula_oldnames
          old_name = old_names[e.name]
          old_name ||= old_names[e.name.split("/").last]
          next if old_name && Bundle::BrewServices.started?(old_name)

          true
        end
      end
    end
  end
end
