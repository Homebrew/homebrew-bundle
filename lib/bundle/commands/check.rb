module Bundle::Commands
  class Check
    def self.reset!
      @dsl = nil
      Bundle::CaskDumper.reset!
      Bundle::BrewDumper.reset!
      Bundle::TapDumper.reset!
    end

    def self.run
      if any_taps_to_tap? || any_casks_to_install? || any_formulae_to_install?
        puts "brew bundle can't satisfy your Brewfile's dependencies."
        puts "Install missing dependencies with `brew bundle install`."
        exit 1
      else
        puts "The Brewfile's dependencies are satisfied."
      end
    end

    private

    def self.any_casks_to_install?
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      requested_casks = @dsl.entries.select { |e| e.type == :cask }.map(&:name)
      return false if requested_casks.empty?
      current_casks = Bundle::CaskDumper.casks
      (requested_casks - current_casks).any?
    end

    def self.any_formulae_to_install?
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      requested_formulae = @dsl.entries.select { |e| e.type == :brew }.map(&:name)
      requested_formulae.any? do |f|
        !Bundle::BrewInstaller.formula_installed_and_up_to_date?(f)
      end
    end

    def self.any_taps_to_tap?
      @dsl ||= Bundle::Dsl.new(Bundle.brewfile)
      requested_taps = @dsl.entries.select { |e| e.type == :tap }.map(&:name)
      return false if requested_taps.empty?
      current_taps = Bundle::TapDumper.tap_names
      (requested_taps - current_taps).any?
    end
  end
end
