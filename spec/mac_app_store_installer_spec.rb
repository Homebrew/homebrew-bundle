# frozen_string_literal: true

require "spec_helper"

describe Bundle::MacAppStoreInstaller do
  def do_install
    Bundle::MacAppStoreInstaller.install("foo", 123)
  end

  context ".installed_app_ids" do
    it "shells out" do
      Bundle::MacAppStoreInstaller.installed_app_ids
    end
  end

  context ".app_id_installed_and_up_to_date?" do
    it "returns result" do
      allow(Bundle::MacAppStoreInstaller).to receive(:installed_app_ids).and_return([123, 456])
      allow(Bundle::MacAppStoreInstaller).to receive(:outdated_app_ids).and_return([456])
      expect(Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date?(123)).to eql(true)
      expect(Bundle::MacAppStoreInstaller.app_id_installed_and_up_to_date?(456)).to eql(false)
    end
  end

  context "when mas is not installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(false)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "tries to install mas" do
      expect(Bundle).to receive(:system).with("brew", "install", "mas").and_return(true)
      expect { do_install }.to raise_error(RuntimeError)
    end

    context ".outdated_app_ids" do
      it "does not shell out" do
        expect(Bundle::MacAppStoreInstaller).not_to receive(:`)
        Bundle::MacAppStoreInstaller.reset!
        Bundle::MacAppStoreInstaller.outdated_app_ids
      end
    end
  end

  context "when mas is installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context ".outdated_app_ids" do
      it "returns app ids" do
        expect(Bundle::MacAppStoreInstaller).to receive(:`).and_return("foo 123")
        Bundle::MacAppStoreInstaller.reset!
        Bundle::MacAppStoreInstaller.outdated_app_ids
      end
    end

    context "when mas is not signed in" do
      before do
        allow(ARGV).to receive(:verbose?).and_return(false)
      end

      it "tries to sign in with mas" do
        expect(Bundle).to receive(:system).with("mas", "account").and_return(false).twice
        expect(Bundle).to receive(:system).with("mas", "signin", "--dialog", "").and_return(true)
        expect { do_install }.to raise_error(RuntimeError)
      end
    end

    context "when mas is signed in" do
      before do
        allow(Bundle).to receive(:mas_signedin?).and_return(true)
        allow(ARGV).to receive(:verbose?).and_return(false)
        allow(Bundle::MacAppStoreInstaller).to receive(:outdated_app_ids).and_return([])
      end

      context "when app is installed" do
        before do
          allow(Bundle::MacAppStoreInstaller).to receive(:installed_app_ids).and_return([123])
        end

        it "skips" do
          expect(Bundle).not_to receive(:system)
          expect(do_install).to eql(:skipped)
        end
      end

      context "when app is outdated" do
        before do
          allow(Bundle::MacAppStoreInstaller).to receive(:installed_app_ids).and_return([123])
          allow(Bundle::MacAppStoreInstaller).to receive(:outdated_app_ids).and_return([123])
        end

        it "upgrades" do
          expect(Bundle).to receive(:system).with("mas", "upgrade", "123").and_return(true)
          expect(do_install).to eql(:success)
        end
      end

      context "when app is not installed" do
        before do
          allow(Bundle::MacAppStoreInstaller).to receive(:installed_app_ids).and_return([])
        end

        it "installs app" do
          expect(Bundle).to receive(:system).with("mas", "install", "123").and_return(true)
          expect(do_install).to eql(:success)
        end
      end
    end
  end
end
