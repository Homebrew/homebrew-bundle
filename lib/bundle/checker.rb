# frozen_string_literal: true

module Bundle
  module Checker
    class Base
      # Implement these in any subclass
      # PACKAGE_TYPE = :pkg
      # PACKAGE_TYPE_NAME = "Package"
      PACKAGE_ACTION_PREDICATE = "needs to be installed or updated."

      def exit_early_check(packages)
        work_to_be_done = packages.find do |pkg|
          !installed_and_up_to_date?(pkg)
        end

        Array(work_to_be_done)
      end

      def full_check(packages)
        packages.reject { |pkg| installed_and_up_to_date? pkg }
                .map { |entry| "#{self.class::PACKAGE_TYPE_NAME} #{entry} #{self.class::PACKAGE_ACTION_PREDICATE}" }
      end

      def checkable_entries(all_entries)
        all_entries.select { |e| e.type == self.class::PACKAGE_TYPE }
          .reject(&Bundle::Bouncer.method(:refused?))
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
          exit_early_check requested
        else
          full_check requested
        end
      end
    end

    module_function

    CheckResult = Struct.new :work_to_be_done, :errors

    CHECKS = {
      taps_to_tap:         "Taps",
      casks_to_install:    "Casks",
      apps_to_install:     "Apps",
      formulae_to_install: "Formulae",
      formulae_to_start:   "Services",
    }.freeze

    def check(exit_on_first_error)
      @dsl ||= Bundle::Dsl.new(Brewfile.read)

      check_method_names = CHECKS.keys

      errors = []
      enumerator = exit_on_first_error ? :find : :map

      work_to_be_done = check_method_names.send(enumerator) do |check_method|
        check_errors = send(check_method)
        any_errors = check_errors.any?
        errors.concat(check_errors) if any_errors
        any_errors
      end

      work_to_be_done = Array(work_to_be_done).flatten.any?

      CheckResult.new work_to_be_done, errors
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

    def formulae_to_start
      Bundle::Checker::BrewServiceChecker.new.find_actionable @dsl.entries
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
