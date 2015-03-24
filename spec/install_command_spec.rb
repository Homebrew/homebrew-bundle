require 'spec_helper'

describe Brewdler::Commands::Install do
  context "when a Brewfile is not found" do
    it "raises an error" do
      expect { Brewdler::Commands::Install.run }.to raise_error
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(Brewdler::BrewInstaller).to receive(:install).and_return(true)
      allow(Brewdler::CaskInstaller).to receive(:install).and_return(true)
      allow(Brewdler::RepoInstaller).to receive(:install).and_return(true)

      allow(File).to receive(:read).
        and_return("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'")
      expect { Brewdler::Commands::Install.run }.to_not raise_error
    end
  end
end
