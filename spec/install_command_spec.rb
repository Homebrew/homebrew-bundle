require 'spec_helper'

describe Bundle::Commands::Install do
  context "when a Brewfile is not found" do
    it "raises an error" do
      allow(ARGV).to receive(:value).and_return(nil)
      expect { Bundle::Commands::Install.run }.to raise_error
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(true)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(true)
      allow(Bundle::RepoInstaller).to receive(:install).and_return(true)

      allow(ARGV).to receive(:value).and_return(nil)
      allow(File).to receive(:read).
        and_return("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'")
      expect { Bundle::Commands::Install.run }.to_not raise_error
    end
  end
end
