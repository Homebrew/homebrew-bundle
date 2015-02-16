module Brewdler::Commands
  class Cleanup
    def self.run
      formulae = formulae_to_uninstall
      return if formulae.empty?
      if ARGV.dry_run?
        puts "Would uninstall:"
        puts_columns formulae
      else
        Kernel.system "brew", "uninstall", "--force", *formulae
        puts "Uninstalled #{formulae.size} formula#{ formulae.size == 1 ? "" : "e"}"
      end
    end

    private

    def self.formulae_to_uninstall
      dsl = Brewdler::Dsl.new(Brewdler.brewfile)
      kept_formulae = dsl.process.entries.select { |e| e.type == :brew }.map(&:name)
      current_formulae = `brew list`.split
      current_formulae - kept_formulae
    end
  end
end
