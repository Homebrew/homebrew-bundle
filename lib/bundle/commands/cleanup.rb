module Bundle::Commands
  class Cleanup
    def self.run
      formulae = formulae_to_uninstall
      taps = taps_to_untap
      if ARGV.dry_run?
        if formulae.any?
          puts "Would uninstall formulae:"
          puts_columns formulae
        end

        if taps.any?
          puts "Would untap:"
          puts_columns taps
        end
      else
        if formulae.any?
          Kernel.system "brew", "uninstall", "--force", *formulae
          puts "Uninstalled #{formulae.size} formula#{ formulae.size == 1 ? "" : "e"}"
        end

        if taps.any?
          Kernel.system "brew", "untap", *taps
        end
      end
    end

    private

    def self.formulae_to_uninstall
      @@dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      kept_formulae = @@dsl.entries.select { |e| e.type == :brew }.map(&:name)
      current_formulae = Bundle::BrewDumper.new.formulae
      current_formulae.reject do |formula|
        kept_formulae.include?(formula[:name]) || kept_formulae.include?(formula[:full_name])
      end.map do |formula|
        formula[:full_name]
      end
    end

    def self.taps_to_untap
      @@dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      kept_taps = @@dsl.entries.select { |e| e.type == :repo }.map(&:name)
      current_taps = `brew tap`.split
      current_taps - kept_taps
    end
  end
end
