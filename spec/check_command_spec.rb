require "spec_helper"

describe Bundle::Commands::Check do
  context "when dependencies are satisfied" do
    it "does not raise an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow(Bundle::Commands::Check).to receive(:casks_to_install).and_return([])
      allow(Bundle::Commands::Check).to receive(:formulae_to_install).and_return([])
      allow(Bundle::Commands::Check).to receive(:taps_to_tap).and_return([])
      expect { Bundle::Commands::Check.run }.to_not raise_error
    end
  end

  context "when casks are not installed" do
    before do
      Bundle::Commands::Check.reset_dsl!
    end

    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:casks).and_return([])
      allow(Bundle::BrewInstaller).to receive(:upgradable_formulae).and_return([])
      allow(Bundle::Commands::Check).to receive(:`).and_return("")
      allow(ARGV).to receive(:include?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read).and_return("cask 'abc'")
      expect { Bundle::Commands::Check.run }.to raise_error(SystemExit)
    end
  end

  context "when formulae are not installed" do
    before do
      Bundle::Commands::Check.reset_dsl!
    end

    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:casks).and_return([])
      allow(Bundle::BrewInstaller).to receive(:upgradable_formulae).and_return([])
      allow(Bundle::Commands::Check).to receive(:`).and_return("")
      allow(ARGV).to receive(:include?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read).and_return("brew 'abc'")
      expect { Bundle::Commands::Check.run }.to raise_error(SystemExit)
    end
  end

  context "when taps are not tapped" do
    before do
      Bundle::Commands::Check.reset_dsl!
    end

    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:casks).and_return([])
      allow(Bundle::BrewInstaller).to receive(:upgradable_formulae).and_return([])
      allow(Bundle::Commands::Check).to receive(:`).and_return("")
      allow(ARGV).to receive(:include?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read).and_return("tap 'abc/def'")
      expect { Bundle::Commands::Check.run }.to raise_error(SystemExit)
    end
  end
end
