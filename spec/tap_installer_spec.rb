# frozen_string_literal: true

require "spec_helper"

describe Bundle::TapInstaller do
  def do_install(options = {})
    Bundle::TapInstaller.install("homebrew/cask", options)
  end

  def do_pinning(options = {})
    Bundle::TapInstaller.check_pinning("homebrew/cask", options)
  end

  context ".installed_taps" do
    it "calls Homebrew" do
      Bundle::TapInstaller.installed_taps
    end
  end

  context ".pinned_installed_taps" do
    it "calls Homebrew" do
      Bundle::TapInstaller.pinned_installed_taps
    end
  end

  context "when tap is installed" do
    before do
      allow(Bundle::TapInstaller).to receive(:installed_taps).and_return(["homebrew/cask"])
      allow(Bundle::TapInstaller).to receive(:pinned_installed_taps).and_return([])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "skips" do
      expect(Bundle).not_to receive(:system)
      expect(do_install).to eql(:skipped)
    end

    context "with pin true" do
      it "pins" do
        expect(Bundle).to receive(:system).with("brew", "tap-pin", "homebrew/cask").and_return(true)
        expect(do_install(pin: true)).to eql(:skipped)
      end
    end
  end

  context "when tap is not installed" do
    before do
      allow(Bundle::TapInstaller).to receive(:installed_taps).and_return([])
      allow(Bundle::TapInstaller).to receive(:pinned_installed_taps).and_return([])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "taps" do
      expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/cask").and_return(true)
      expect(do_install).to eql(:success)
    end

    context "with clone target" do
      it "taps" do
        expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/cask", "clone_target_path").and_return(true)
        expect(do_install(clone_target: "clone_target_path")).to eql(:success)
      end
    end

    context "with pin true" do
      it "pins" do
        expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/cask").and_return(true)
        expect(Bundle).to receive(:system).with("brew", "tap-pin", "homebrew/cask").and_return(true)
        expect(do_install(pin: true)).to eql(:success)
      end
    end
  end

  context "when tap is pinned" do
    before do
      allow(Bundle::TapInstaller).to receive(:installed_taps).and_return(["homebrew/cask"])
      allow(Bundle::TapInstaller).to receive(:pinned_installed_taps).and_return(["homebrew/cask"])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "with pin false" do
      it "unpins" do
        expect(Bundle).to receive(:system).with("brew", "tap-unpin", "homebrew/cask").and_return(true)
        expect(do_install).to eql(:skipped)
      end
    end
  end

  context "when tap needs pinning" do
    before do
      allow(Bundle::TapInstaller).to receive(:pinned_installed_taps).and_return([])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "pins" do
      expect(Bundle).to receive(:system).with("brew", "tap-pin", "homebrew/cask").and_return(true)
      expect(do_pinning(pin: true)).to eql(:success)
    end
  end

  context "when tap needs unpinning" do
    before do
      allow(Bundle::TapInstaller).to receive(:pinned_installed_taps).and_return(["homebrew/cask"])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "pins" do
      expect(Bundle).to receive(:system).with("brew", "tap-unpin", "homebrew/cask").and_return(true)
      expect(do_pinning).to eql(:success)
    end
  end
end
