module Bundle::Commands
  class Check
    def self.run
      if casks_to_install.any? || formulae_to_install.any? || taps_to_tap.any?
        puts "brew bundle can't satisfy your Brewfile's dependencies."
        puts "Install missing dependencies with `brew bundle install`."
        exit 1
      else
        puts "The Brewfile's dependencies are satisfied."
      end
    end

    private

    def self.casks_to_install
      @@dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      requested_casks = @@dsl.entries.select { |e| e.type == :cask }.map(&:name)
      current_casks = Bundle::CaskDumper.new.casks
      requested_casks - current_casks
    end

    def self.formulae_to_install
      @@dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      requested_formulae = @@dsl.entries.select { |e| e.type == :brew }.map(&:name)
      requested_formulae.map! { |f| f.split("/").last }
      current_formulae = Bundle::BrewDumper.new.formulae.map { |f| f[:name] }
      upgradable_formulae = Bundle::BrewInstaller.upgradable_formulae
      requested_formulae - (current_formulae - upgradable_formulae)
    end

    def self.taps_to_tap
      @@dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      requested_taps = @@dsl.entries.select { |e| e.type == :tap }.map(&:name)
      current_taps = `brew tap`.split
      requested_taps - current_taps
    end
  end
end
