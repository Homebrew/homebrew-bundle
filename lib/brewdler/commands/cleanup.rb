module Brewdler::Commands
  class Cleanup
    def self.run
      formulae = formulae_to_uninstall
      taps = taps_to_untap
      if ARGV.dry_run?
        if formulae.any?
          puts "Would uninstall:"
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
      @@dsl ||= Brewdler::Dsl.new(Brewdler.brewfile).process
      kept_formulae = @@dsl.entries.select { |e| e.type == :brew }.map(&:name)
      current_formulae = `brew list`.split
      current_formulae - kept_formulae
    end

    def self.taps_to_untap
      @@dsl ||= Brewdler::Dsl.new(Brewdler.brewfile).process
      kept_taps = @@dsl.entries.select { |e| e.type == :repo }.map(&:name)
      current_taps = `brew tap`.split
      current_taps - kept_taps
    end
  end
end
