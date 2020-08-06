# frozen_string_literal: true

require "spec_helper"

describe Bundle::CaskInstaller do
  def do_install
    Bundle::CaskInstaller.install("google-chrome")
  end

  describe ".installed_casks" do
    it "shells out" do
      described_class.installed_casks
    end
  end

  describe ".cask_installed_and_up_to_date?" do
    it "returns result" do
      described_class.reset!
      allow(described_class).to receive(:installed_casks).and_return(["foo", "baz"])
      allow(described_class).to receive(:outdated_casks).and_return(["baz"])
      expect(described_class.cask_installed_and_up_to_date?("foo")).to be(true)
      expect(described_class.cask_installed_and_up_to_date?("baz")).to be(false)
    end
  end

  context "when brew-cask is not installed" do
    describe ".outdated_casks" do
      it "does not shell out" do
        allow(Bundle).to receive(:cask_installed?).and_return(false)
        expect(described_class).not_to receive(:`)
        described_class.reset!
        described_class.outdated_casks
      end
    end
  end

  context "when brew-cask is installed" do
    before do
      allow(Bundle).to receive(:cask_installed?).and_return(true)
    end

    describe ".outdated_casks" do
      it "shells out" do
        allow(Bundle).to receive(:cask_installed?).and_return(true)
        expect(described_class).to receive(:`).and_return("")
        described_class.reset!
        described_class.outdated_casks
      end
    end

    context "when cask is installed" do
      before do
        allow(described_class).to receive(:installed_casks).and_return(["google-chrome"])
      end

      it "skips" do
        expect(Bundle).not_to receive(:system)
        expect(do_install).to be(:skipped)
      end
    end

    context "when cask is outdated" do
      before do
        allow(described_class).to receive(:installed_casks).and_return(["google-chrome"])
        allow(described_class).to receive(:outdated_casks).and_return(["google-chrome"])
      end

      it "upgrades" do
        expect(Bundle).to receive(:system).with("brew", "cask", "upgrade", "google-chrome", verbose: false)
                                          .and_return(true)
        expect(do_install).to be(:success)
      end
    end

    context "when cask is not installed" do
      before do
        allow(described_class).to receive(:installed_casks).and_return([])
      end

      it "installs cask" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "google-chrome", verbose: false)
                                          .and_return(true)
        expect(do_install).to be(:success)
      end

      it "installs cask with arguments" do
        expect(Bundle).to \
          receive(:system).with("brew", "cask", "install", "firefox", "--appdir=/Applications", verbose: false)
                          .and_return(true)
        expect(described_class.install("firefox", args: { appdir: "/Applications" })).to eq(:success)
      end

      it "reports a failure" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "google-chrome", verbose: false)
                                          .and_return(false)
        expect(do_install).to be(:failed)
      end

      context "with boolean arguments" do
        it "includes a flag if true" do
          expect(Bundle).to receive(:system).with("brew", "cask", "install", "iterm", "--force", verbose: false)
                                            .and_return(true)
          expect(described_class.install("iterm", args: { force: true })).to eq(:success)
        end

        it "does not include a flag if false" do
          expect(Bundle).to receive(:system).with("brew", "cask", "install", "iterm", verbose: false).and_return(true)
          expect(described_class.install("iterm", args: { force: false })).to eq(:success)
        end
      end
    end
  end
end
