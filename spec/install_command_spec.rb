require "spec_helper"

describe Bundle::Commands::Install do
  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  context "when a Brewfile is not found" do
    it "raises an error" do
      allow(ARGV).to receive(:value).and_return(nil)
      expect { Bundle::Commands::Install.run }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(:success)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:skipped)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:success)
      allow(Bundle::TapInstaller).to receive(:install).and_return(:skipped)

      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\nmas '1Password', id: 443987910")
      expect { Bundle::Commands::Install.run }.to_not raise_error
    end

    it "exits on failures" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::TapInstaller).to receive(:install).and_return(:failed)

      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\n\nmas '1Password', id: 443987910")
      expect { Bundle::Commands::Install.run }.to raise_error(SystemExit)
    end
  end
end
