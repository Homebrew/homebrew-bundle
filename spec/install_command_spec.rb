require "spec_helper"

describe Bundle::Commands::Install do
  context "when a Brewfile is not found" do
    it "raises an error" do
      allow(ARGV).to receive(:value).and_return(nil)
      expect { Bundle::Commands::Install.run }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(true)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(true)
      allow(Bundle::TapInstaller).to receive(:install).and_return(true)

      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read).
        and_return("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'")
      expect { Bundle::Commands::Install.run }.to_not raise_error
    end

    it "exits on failures" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(false)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(false)
      allow(Bundle::TapInstaller).to receive(:install).and_return(false)

      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read).
        and_return("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'")
      expect { Bundle::Commands::Install.run }.to raise_error(SystemExit)
    end
  end
end
