# frozen_string_literal: true

module Bundle
  module Commands
    module Check
      module_function

      ARROW = "→".freeze

      def reset!
        @dsl = nil
        Bundle::CaskDumper.reset!
        Bundle::BrewDumper.reset!
        Bundle::MacAppStoreDumper.reset!
        Bundle::TapDumper.reset!
        Bundle::BrewServices.reset!
      end

      def exit_on_first_error?
        Bundle::Checker.exit_on_first_error?
      end

      def output_errors?
        ARGV.include?("--verbose")
      end

      def run
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)

        checks = {
          taps_to_tap: "Taps",
          casks_to_install: "Casks",
          apps_to_install: "Apps",
          formulae_to_install: "Formulae",
        }
        check_method_names = checks.keys

        completed_checks = []
        errors = []
        enumerator = exit_on_first_error? ? :any? : :map

        work_to_be_done = check_method_names.send(enumerator) do |check_method|
          check_errors = send(check_method)
          completed_checks << check_method
          any_errors = check_errors.any?
          errors.concat(check_errors) if any_errors
          any_errors
        end

        work_to_be_done = work_to_be_done.any? if work_to_be_done.class == Array

        if work_to_be_done
          puts "brew bundle can't satisfy your Brewfile's dependencies."

          if output_errors?
            unchecked_checks = (checks.keys - completed_checks)
            completed_checks.each { |checked| puts "#{checks[checked]} were checked." }
            unchecked_checks.each { |unchecked| puts "#{checks[unchecked]} were not checked." }
            errors.each { |package| puts "#{ARROW} #{package}" }
          end
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        elsif any_formulae_to_start?
          puts "brew bundle can't satisfy your Brewfile's dependencies."
          puts "At least one brew formula must be started."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end

      def casks_to_install
        Bundle::CaskChecker.find_actionable @dsl.entries
      end

      def formulae_to_install
        Bundle::BrewChecker.find_actionable @dsl.entries
      end

      def taps_to_tap
        Bundle::TapChecker.find_actionable @dsl.entries
      end

      def apps_to_install
        Bundle::MacAppStoreChecker.find_actionable @dsl.entries
      end

      def any_formulae_to_start?
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
