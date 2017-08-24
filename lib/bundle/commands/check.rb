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
        pending = {
          'missing taps' => taps_to_tap,
          'casks to install' => casks_to_install,
          'apps to install' => apps_to_install,
          'formulae to upgrade' => formulae_to_install,
          'services to start' => formulae_to_start
        }

        if pending.values.any?(&:any?)
          puts "brew bundle can't satisfy your Brewfile's dependencies."
          pending.each { |kind, items| puts "  * #{items.count} #{kind}" }
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end

      def casks_to_install
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_casks = @dsl.entries.select { |e| e.type == :cask }.map(&:name)
        return [] if requested_casks.empty?
        current_casks = Bundle::CaskDumper.casks
        requested_casks - current_casks
      end

      def formulae_to_install
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
        requested_formulae.reject do |f|
          Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
        end
      end

      def taps_to_tap
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
        return [] if requested_taps.empty?
        current_taps = Bundle::TapDumper.tap_names
        requested_taps - current_taps
      end

      def apps_to_install
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        requested_apps = @dsl.entries.select { |e| e.type == :mac_app_store }.map { |e| e.options[:id] }
        return [] if requested_apps.empty?
        current_apps = Bundle::MacAppStoreDumper.app_ids
        requested_apps - current_apps
      end

      def formulae_to_start
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        @dsl.entries.select { |e| e.type == :brew }.select do |e|
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
