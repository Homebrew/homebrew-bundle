# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::Install do
  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  context "when a Brewfile is not found" do
    it "raises an error" do
      allow(ARGV).to receive(:value).and_return(nil)
      expect { described_class.run }.to raise_error(RuntimeError)
    end
  end

  context "when an installer raises an error" do
    it "does not bubble the error to the top" do
      allow(ARGV).to receive(:value).and_return(nil)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_throw(RuntimeError)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("mas 'Should Not Exist', id: 0")
      expect { described_class.run }.not_to raise_error
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
      expect { described_class.run }.not_to raise_error
    end

    it "exits on failures" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::TapInstaller).to receive(:install).and_return(:failed)

      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\n\nmas '1Password', id: 443987910")
      expect { described_class.run }.to raise_error(SystemExit)
    end
  end
end
