# frozen_string_literal: true

require "spec_helper"

describe Bundle::TapInstaller do
  def do_install(**options)
    Bundle::TapInstaller.install("homebrew/cask", **options)
  end

  def do_pinning(**options)
    Bundle::TapInstaller.check_pinning("homebrew/cask", **options)
  end

  describe ".installed_taps" do
    it "calls Homebrew" do
      described_class.installed_taps
    end
  end

  describe ".pinned_installed_taps" do
    it "calls Homebrew" do
      described_class.pinned_installed_taps
    end
  end

  context "when tap is installed" do
    before do
      allow(described_class).to receive(:installed_taps).and_return(["homebrew/cask"])
      allow(described_class).to receive(:pinned_installed_taps).and_return([])
    end

    it "skips" do
      expect(Bundle).not_to receive(:system)
      expect(do_install).to be(:skipped)
    end

    context "with pin true" do
      it "pins" do
        expect(Bundle).to receive(:system).with("brew", "tap-pin", "homebrew/cask", verbose: false).and_return(true)
        expect(do_install(pin: true)).to be(:skipped)
      end
    end
  end

  context "when tap is not installed" do
    before do
      allow(described_class).to receive(:installed_taps).and_return([])
      allow(described_class).to receive(:pinned_installed_taps).and_return([])
    end

    it "taps" do
      expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/cask", verbose: false).and_return(true)
      expect(do_install).to be(:success)
    end

    context "with clone target" do
      it "taps" do
        expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/cask", "clone_target_path", verbose: false)
                                          .and_return(true)
        expect(do_install(clone_target: "clone_target_path")).to be(:success)
      end
    end

    context "with pin true" do
      it "pins" do
        expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/cask", verbose: false).and_return(true)
        expect(Bundle).to receive(:system).with("brew", "tap-pin", "homebrew/cask", verbose: false).and_return(true)
        expect(do_install(pin: true)).to be(:success)
      end
    end
  end

  context "when tap is pinned" do
    before do
      allow(described_class).to receive(:installed_taps).and_return(["homebrew/cask"])
      allow(described_class).to receive(:pinned_installed_taps).and_return(["homebrew/cask"])
    end

    context "with pin false" do
      it "unpins" do
        expect(Bundle).to receive(:system).with("brew", "tap-unpin", "homebrew/cask", verbose: false).and_return(true)
        expect(do_install).to be(:skipped)
      end
    end
  end

  context "when tap needs pinning" do
    before do
      allow(described_class).to receive(:pinned_installed_taps).and_return([])
    end

    it "pins" do
      expect(Bundle).to receive(:system).with("brew", "tap-pin", "homebrew/cask", verbose: false).and_return(true)
      expect(do_pinning(pin: true)).to be(:success)
    end
  end

  context "when tap needs unpinning" do
    before do
      allow(described_class).to receive(:pinned_installed_taps).and_return(["homebrew/cask"])
    end

    it "pins" do
      expect(Bundle).to receive(:system).with("brew", "tap-unpin", "homebrew/cask", verbose: false).and_return(true)
      expect(do_pinning).to be(:success)
    end
  end
end
