require 'spec_helper'

describe Brewdler::Commands::Install do
  context "when a Brewfile is not found" do
    it "raises an error" do
      expect { Brewdler::Commands::Install.run }.to raise_error
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      Brewdler::BrewInstaller.stub(:install).and_return(true)
      Brewdler::CaskInstaller.stub(:install).and_return(true)

      File.stub(:read).and_return("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'")
      expect { Brewdler::Commands::Install.run }.to_not raise_error

      File.stub(:read => 'git', :open => ['git'])
      expect { Brewdler::Commands::Install.run }.to_not raise_error
    end
  end
end
