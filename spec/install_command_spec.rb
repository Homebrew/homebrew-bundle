require "spec_helper"

describe Bundle::Commands::Install do
  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  context "when a Brewfile is not found" do
    it "raises an error" do
      allow(ARGV).to receive_messages(:value => nil, :values => nil)
      expect { Bundle::Commands::Install.run }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(:success)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:skipped)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:success)
      allow(Bundle::TapInstaller).to receive(:install).and_return(:skipped)

      allow(ARGV).to receive_messages(:value => nil, :values => nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\nmas '1Password', id: 443987910")
      expect { Bundle::Commands::Install.run }.to_not raise_error
    end

    it "exits on failures" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::TapInstaller).to receive(:install).and_return(:failed)

      allow(ARGV).to receive_messages(:value => nil, :values => nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\n\nmas '1Password', id: 443987910")
      expect { Bundle::Commands::Install.run }.to raise_error(SystemExit)
    end
  end

  context "when --without=default is given" do
    it "installs nothing" do
      expect(Bundle::BrewInstaller).not_to receive(:install)
      expect(Bundle::CaskInstaller).not_to receive(:install)
      expect(Bundle::MacAppStoreInstaller).not_to receive(:install)
      expect(Bundle::TapInstaller).not_to receive(:install)

      allow(ARGV).to receive_messages(:value => nil, :values => nil)
      allow(ARGV).to receive(:values).with(:without).and_return(["default"])
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\nmas '1Password', id: 443987910")
      expect { Bundle::Commands::Install.run }.to_not raise_error
    end
  end

  context "when --without=my,fancy,group is given" do
    it "installs entries only outside of myfancygroup" do
      expect(Bundle::BrewInstaller).not_to receive(:install)
      expect(Bundle::CaskInstaller).not_to receive(:install)
      expect(Bundle::MacAppStoreInstaller).not_to receive(:install)
      expect(Bundle::TapInstaller).to receive(:install).and_return(true)

      allow(ARGV).to receive_messages(:value => nil, :values => nil)
      allow(ARGV).to receive(:values).with(:without).and_return(%w[my fancy group])
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\ngroup 'my' do\nbrew 'mysql', conflicts_with: ['mysql56']\nend\ngroup 'fancy' do\ncask 'google-chrome'\nend\ngroup 'group' do\nmas '1Password', id: 443987910\nend")
      expect { Bundle::Commands::Install.run }.to_not raise_error
    end
  end
end
