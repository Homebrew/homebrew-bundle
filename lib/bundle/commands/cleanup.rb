module Bundle::Commands
  class Cleanup
    def self.reset!
      @dsl = nil
      Bundle::CaskDumper.reset!
      Bundle::BrewDumper.reset!
      Bundle::TapDumper.reset!
    end

    def self.run
      casks = casks_to_uninstall
      formulae = formulae_to_uninstall
      taps = taps_to_untap
      unless ARGV.force?
        if casks.any?
          puts "Would uninstall casks:"
          puts_columns casks
        end

        if formulae.any?
          puts "Would uninstall formulae:"
          puts_columns formulae
        end

        if taps.any?
          puts "Would untap:"
          puts_columns taps
        end
      else
        if casks.any?
          if ARGV.include?("--zap")
            action = "zap"
          else
            action = "uninstall"
          end

          Kernel.system "brew", "cask", action, "--force", *casks
          puts "Uninstalled #{casks.size} cask#{casks.size == 1 ? "" : "s"}"
        end

        if formulae.any?
          Kernel.system "brew", "uninstall", "--force", *formulae
          puts "Uninstalled #{formulae.size} formula#{formulae.size == 1 ? "" : "e"}"
        end

        if taps.any?
          Kernel.system "brew", "untap", *taps
        end
      end
    end

    private

    def self.casks_to_uninstall
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      kept_casks = @dsl.entries.select { |e| e.type == :cask }.map(&:name)
      current_casks = Bundle::CaskDumper.casks
      current_casks - kept_casks
    end

    def self.formulae_to_uninstall
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      kept_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
      kept_formulae.map! { |f| Bundle::BrewDumper.formula_aliases[f] || f }
      current_formulae = Bundle::BrewDumper.formulae
      current_formulae.reject do |f|
        Bundle::BrewInstaller.formula_in_array?(f[:full_name], kept_formulae)
      end.map { |f| f[:full_name] }
    end

    def self.taps_to_untap
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      kept_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
      current_taps = Bundle::TapDumper.tap_names
      current_taps - kept_taps
    end
  end
end
