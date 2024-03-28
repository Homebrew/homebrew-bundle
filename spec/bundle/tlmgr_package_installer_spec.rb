# frozen_string_literal: true

require "spec_helper"

describe Bundle::TlmgrPackageInstaller do
  context "when Tex Live package manager is not installed" do
    before do
      described_class.reset!
      allow(Bundle).to receive_messages(tlmgr_installed?: false)
    end

    it "raises an error" do
      expect { Bundle }.to raise_error(RuntimeError).and_return(false)
      expect { described_class.preinstall("foo") }.to raise_error(RuntimeError)
    end
  end

  context "when TeX Live package manager is installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(true)
    end

    context "when package is installed" do
      before do
        allow(described_class).to receive(:installed_packages).and_return(["foo"])
      end

      it "skips" do
        expect(Bundle).not_to receive(:system)
        expect(described_class.preinstall("foo")).to be(false)
      end

      it "skips ignoring case" do
        expect(Bundle).not_to receive(:system)
        expect(described_class.preinstall("Foo")).to be(false)
      end
    end

    context "when package is not installed" do
      before do
        allow(described_class).to receive(:installed_extensions).and_return([])
      end

      it "installs extension" do
        expect(Bundle).to receive(:system).with("sudo", "tlmgr", "install", "foo", verbose: false).and_return(true)
        expect(described_class.preinstall("foo")).to be(true)
        expect(described_class.install("foo")).to be(true)
      end
    end
  end
end
