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
        formulae = formulae_to_uninstall
        taps = taps_to_untap
        if ARGV.force?
          if casks.any?
            Kernel.system "brew", "cask", "uninstall", "--force", *casks
            puts "Uninstalled #{casks.size} cask#{(casks.size == 1) ? "" : "s"}"
          end

          if formulae.any?
            Kernel.system "brew", "uninstall", "--force", *formulae
            puts "Uninstalled #{formulae.size} formula#{(formulae.size == 1) ? "" : "e"}"
          end

          Kernel.system "brew", "untap", *taps if taps.any?
        else
          require "utils/formatter"

          if casks.any?
            puts "Would uninstall casks:"
            puts Formatter.columns casks
          end

          if formulae.any?
            puts "Would uninstall formulae:"
            puts Formatter.columns formulae
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

      def formulae_to_uninstall
        @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
        kept_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
        kept_formulae.map! do |f|
          Bundle::BrewDumper.formula_aliases[f] ||
            Bundle::BrewDumper.formula_oldnames[f] ||
            f
        end

        current_formulae = Bundle::BrewDumper.formulae
        kept_formulae += recursive_dependencies(current_formulae, kept_formulae)
        current_formulae.reject! do |f|
          Bundle::BrewInstaller.formula_in_array?(f[:full_name], kept_formulae)
        end
        current_formulae.map { |f| f[:full_name] }
      end

      def recursive_dependencies(current_formulae, formulae_names, top_level = true)
        @checked_formulae_names = [] if top_level
        dependencies = []

        formulae_names.each do |name|
          next if @checked_formulae_names.include?(name)
          formula = current_formulae.find { |f| f[:name] == name }
          next unless formula
          f_deps = formula[:dependencies]
          next unless f_deps
          next if f_deps.empty?
          @checked_formulae_names << name
          f_deps += recursive_dependencies(current_formulae, f_deps, false)
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
