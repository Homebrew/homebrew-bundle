# frozen_string_literal: true

module Bundle
  module Commands
    module Check
      module_function

      @arrow = "\u21B3".encode("utf-8")

      def reset!
        @dsl = nil
        Bundle::CaskDumper.reset!
        Bundle::BrewDumper.reset!
        Bundle::MacAppStoreDumper.reset!
        Bundle::TapDumper.reset!
        Bundle::BrewServices.reset!
      end

      def run
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)

        work_to_be_done = [taps_to_tap, casks_to_install, formulae_to_install, apps_to_install].flatten.reject { |p| p.nil? || p == false }

        if work_to_be_done.any? || any_formulae_to_start?
          puts "brew bundle can't satisfy your Brewfile's dependencies."
          work_to_be_done.each { |package| puts "#{@arrow} #{package}" }
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end

      def casks_to_install
        requested_casks = @dsl.entries.select { |e| e.type == :cask }.map(&:name)
        actionable = requested_casks.reject do |c|
          Bundle::CaskInstaller.cask_installed_and_up_to_date?(c)
        end
        actionable.map { |entry| "Cask #{entry} needs to be installed or updated." }
      end

      def formulae_to_install
        requested_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
        actionable = requested_formulae.reject do |f|
          Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
        end
        actionable.map { |entry| "Formula #{entry} needs to be installed or updated." }
      end

      def taps_to_tap
        requested_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
        return false if requested_taps.empty?
        current_taps = Bundle::TapDumper.tap_names
        (requested_taps - current_taps).map { |entry| "Tap #{entry} needs to be tapped." }
      end

      def apps_to_install
        requested_app_ids = @dsl.entries.select { |e| e.type == :mac_app_store }.map { |e| [e.options[:id], e.name] }.to_h
        actionable = requested_app_ids.reject do |id, _name|
          Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date?(id)
        end
        actionable.map { |_id, name| "App #{name} needs to be installed or updated." }
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
