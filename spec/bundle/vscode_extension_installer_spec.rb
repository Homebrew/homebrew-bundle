# frozen_string_literal: true

require "spec_helper"

describe Bundle::VscodeExtensionInstaller do
  context "when VSCode is not installed" do
    before do
      described_class.reset!
      allow(Bundle).to receive(:vscode_installed?).and_return(false)
      allow(Bundle).to receive(:cask_installed?).and_return(true)
    end

    it "tries to install mas" do
      expect(Bundle).to \
        receive(:system).with(HOMEBREW_BREW_FILE, "install", "--cask", "visual-studio-code", verbose: false)
                        .and_return(true)
      expect { described_class.preinstall("foo") }.to raise_error(RuntimeError)
    end
  end

  context "when VSCode is installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(true)
    end

    context "when app is installed" do
      before do
        allow(described_class).to receive(:installed_extensions).and_return(["foo"])
      end

      it "skips" do
        expect(Bundle).not_to receive(:system)
        expect(described_class.preinstall("foo")).to be(false)
      end
    end

    context "when app is not installed" do
      before do
        allow(described_class).to receive(:installed_extensions).and_return([])
      end

      it "installs extension" do
        expect(Bundle).to receive(:system).with("code", "--install-extension", "foo", verbose: false).and_return(true)
        expect(described_class.preinstall("foo")).to be(true)
        expect(described_class.install("foo")).to be(true)
      end
    end
  end
end
