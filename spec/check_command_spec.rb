require "spec_helper"

describe Bundle::Commands::Install do
  context "when a Brewfile is not found" do
    it "raises an error" do
      expect { Bundle::Commands::Check.run }.to raise_error
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(Bundle::Commands::Check).to receive(:casks_to_install).and_return([])
      allow(Bundle::Commands::Check).to receive(:formulae_to_install).and_return([])
      allow(Bundle::Commands::Check).to receive(:taps_to_tap).and_return([])

      allow(File).to receive(:read).
        and_return("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'")
      expect { Bundle::Commands::Check.run }.to_not raise_error
    end
  end
end
