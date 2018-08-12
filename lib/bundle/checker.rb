# frozen_string_literal: true

module Bundle
  module Checker
    class Base
      PACKAGE_TYPE = :pkg
      PACKAGE_TYPE_NAME = "Package"

      NO_ACTION = [].freeze

      def action_required_for(formula)
        [formula]
      end

      def exit_early_check(packages)
        work_to_be_done = packages.find do |pkg|
          yield pkg
        end
        if work_to_be_done
          action_required_for(work_to_be_done)
        else
          NO_ACTION
        end
      end

      def full_check(packages)
        packages.reject { |f| installed_and_up_to_date? f }
                .map { |entry| "#{self.class::PACKAGE_TYPE_NAME} #{entry} needs to be installed or updated." }
      end

      def checkable_entries(all_entries)
        all_entries.select { |e| e.type == self.class::PACKAGE_TYPE }
      end

      def format_checkable(entries)
        checkable_entries(entries).map(&:name)
      end

      def installed_and_up_to_date?(_pkg)
        raise NotImplementedError
      end

      def find_actionable(entries)
        requested = format_checkable entries

        if Bundle::Commands::Check.exit_on_first_error?
          exit_early_check(requested) { |pkg| !installed_and_up_to_date?(pkg) }
        else
          full_check requested
        end
      end
    end

    module_function

    CheckResult = Struct.new :work_to_be_done, :completed_checks, :errors, :unchecked_checks

    CHECKS = {
      taps_to_tap: "Taps",
      casks_to_install: "Casks",
      apps_to_install: "Apps",
      formulae_to_install: "Formulae",
    }.freeze

    def check(exit_on_first_error)
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)

      check_method_names = CHECKS.keys

      completed_checks = []
      errors = []
      enumerator = exit_on_first_error ? :any? : :map

      work_to_be_done = check_method_names.send(enumerator) do |check_method|
        check_errors = send(check_method)
        completed_checks << check_method
        any_errors = check_errors.any?
        errors.concat(check_errors) if any_errors
        any_errors
      end

      work_to_be_done = work_to_be_done.any? if work_to_be_done.class == Array

      unchecked_checks = (check_method_names - completed_checks)

      CheckResult.new work_to_be_done, completed_checks, errors, unchecked_checks
    end

    def casks_to_install
      Bundle::Checker::CaskChecker.new.find_actionable @dsl.entries
    end

    def formulae_to_install
      Bundle::Checker::BrewChecker.new.find_actionable @dsl.entries
    end

    def taps_to_tap
      Bundle::Checker::TapChecker.new.find_actionable @dsl.entries
    end

    def apps_to_install
      Bundle::Checker::MacAppStoreChecker.new.find_actionable @dsl.entries
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

    def reset!
      @dsl = nil
      Bundle::CaskDumper.reset!
      Bundle::BrewDumper.reset!
      Bundle::MacAppStoreDumper.reset!
      Bundle::TapDumper.reset!
      Bundle::BrewServices.reset!
    end
  end
end
