# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::Install do
  before do
    allow_any_instance_of(IO).to receive(:puts)
    allow(Bundle::Locker).to receive(:write_lockfile?).and_return(false)
  end

  context "when a Brewfile is not found" do
    it "raises an error" do
      allow_any_instance_of(Pathname).to receive(:read).and_raise(Errno::ENOENT)
      expect { described_class.run }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    let(:brewfile_contents) do
      <<~EOS
        tap 'phinze/cask'
        brew 'mysql', conflicts_with: ['mysql56']
        cask 'google-chrome'
        mas '1Password', id: 443987910
        whalebrew 'whalebrew/wget'
      EOS
    end

    it "does not raise an error" do
      expect(Bundle::BrewInstaller).to receive(:install).and_return(:success)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:skipped)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:success)
      expect(Bundle::TapInstaller).to receive(:install).and_return(:skipped)
      expect(Bundle::WhalebrewInstaller).to receive(:install).and_return(:skipped)
      allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
      expect { described_class.run }.not_to raise_error
    end

    it "does not raise an error when skippable" do
      expect(Bundle::BrewInstaller).not_to receive(:install)

      allow(Bundle::Skipper).to receive(:skip?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'mysql'")
      expect { described_class.run }.not_to raise_error
    end

    it "exits on failures" do
      allow(Bundle::BrewInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::CaskInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::MacAppStoreInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::TapInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::WhalebrewInstaller).to receive(:install).and_return(:failed)
      allow(Bundle::Locker).to receive(:lockfile).and_return(Pathname(__dir__))
      allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)

      expect { described_class.run }.to raise_error(SystemExit)
    end

    context "when installing only a certain type of entry" do
      it "installs only brews" do
        expect(Bundle::BrewInstaller).to receive(:install).and_return(:success)
        expect(Bundle::CaskInstaller).not_to receive(:install)
        expect(Bundle::MacAppStoreInstaller).not_to receive(:install)
        expect(Bundle::TapInstaller).not_to receive(:install)
        expect(Bundle::WhalebrewInstaller).not_to receive(:install)
        allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
        expect do
          described_class.run(
            global: false, file: nil,
            brews: true, casks: false, mas: false, whalebrew: false, taps: false,
            no_lock: false, no_upgrade: false, verbose: false
          )
        end.not_to raise_error
      end

      it "installs both brews and mas but nothing else" do
        expect(Bundle::BrewInstaller).to receive(:install).and_return(:success)
        expect(Bundle::CaskInstaller).not_to receive(:install)
        expect(Bundle::MacAppStoreInstaller).not_to receive(:install)
        expect(Bundle::TapInstaller).not_to receive(:install)
        expect(Bundle::WhalebrewInstaller).to receive(:install).and_return(:success)
        allow_any_instance_of(Pathname).to receive(:read).and_return(brewfile_contents)
        expect do
          described_class.run(
            global: false, file: nil,
            brews: true, casks: false, mas: false, whalebrew: true, taps: false,
            no_lock: false, no_upgrade: false, verbose: false
          )
        end.not_to raise_error
      end
    end
  end
end
