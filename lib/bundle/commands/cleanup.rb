# frozen_string_literal: true

module Bundle
  module Commands
    module Cleanup
      module_function

      def reset!
        @dsl = nil
        Bundle::CaskDumper.reset!
        Bundle::BrewDumper.reset!
        Bundle::TapDumper.reset!
        Bundle::BrewServices.reset!
      end

      def run
        casks = casks_to_uninstall
        formulas = formulas_to_uninstall
        taps = taps_to_untap
        if ARGV.force?
          if casks.any?
            action = if ARGV.include?("--zap")
              "zap"
            else
              "uninstall"
            end

            Kernel.system "brew", "cask", action, "--force", *casks
            puts "Uninstalled #{casks.size} cask#{(casks.size == 1) ? "" : "s"}"
          end

          if formulas.any?
            Kernel.system "brew", "uninstall", "--force", *formulas
            puts "Uninstalled #{formulas.size} formula#{(formulas.size == 1) ? "" : "e"}"
          end

          Kernel.system "brew", "untap", *taps if taps.any?
        else
          require "utils/formatter"

          if casks.any?
            puts "Would uninstall casks:"
            puts Formatter.columns casks
          end

          if formulas.any?
            puts "Would uninstall formulas:"
            puts Formatter.columns formulas
          end

          if taps.any?
            puts "Would untap:"
            puts Formatter.columns taps
          end
        end
      end

      def casks_to_uninstall
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        kept_casks = @dsl.entries.select { |e| e.type == :cask }.map(&:name)
        current_casks = Bundle::CaskDumper.casks
        current_casks - kept_casks
      end

      def formulas_to_uninstall
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        kept_formulas = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
        kept_formulas.map! do |f|
          Bundle::BrewDumper.formula_aliases[f] ||
            Bundle::BrewDumper.formula_oldnames[f] ||
            f
        end

        current_formulas = Bundle::BrewDumper.formulas
        kept_formulas += recursive_dependencies(current_formulas, kept_formulas)
        current_formulas.reject! do |f|
          Bundle::BrewInstaller.formula_in_array?(f[:full_name], kept_formulas)
        end
        current_formulas.map { |f| f[:full_name] }
      end

      def recursive_dependencies(current_formulas, formulas_names, top_level = true)
        @checked_formulas_names = [] if top_level
        dependencies = []

        formulas_names.each do |name|
          next if @checked_formulas_names.include?(name)
          formula = current_formulas.find { |f| f[:full_name] == name }
          next unless formula
          f_deps = formula[:dependencies]
          unless formula[:poured_from_bottle?]
            f_deps += formula[:build_dependencies]
            f_deps.uniq!
          end
          next unless f_deps
          next if f_deps.empty?
          @checked_formulas_names << name
          f_deps += recursive_dependencies(current_formulas, f_deps, false)
          dependencies += f_deps
        end

        dependencies.uniq
      end

      IGNORED_TAPS = %w[homebrew/core homebrew/bundle].freeze

      def taps_to_untap
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        kept_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
        current_taps = Bundle::TapDumper.tap_names
        current_taps - kept_taps - IGNORED_TAPS
      end
    end
  end
end
