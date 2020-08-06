# frozen_string_literal: true

require "spec_helper"

describe Bundle::WhalebrewInstaller do
  def do_install
    Bundle::WhalebrewInstaller.install("whalebrew/wget")
  end

  describe ".installed_images" do
    it "shells out" do
      described_class.installed_images
    end
  end

  describe ".image_installed?" do
    context "when an image is already installed" do
      before do
        described_class.reset!
      end

      it "returns true" do
        allow(Bundle::WhalebrewDumper).to receive(:images).and_return(["whalebrew/wget"])
        expect(described_class.image_installed?("whalebrew/wget")).to eq(true)
      end
    end

    context "when an image isn't installed" do
      before do
        described_class.reset!
      end

      it "returns false" do
        allow(Bundle::WhalebrewDumper).to receive(:images).and_return([])
        expect(described_class.image_installed?("test/doesnotexist")).to eq(false)
      end
    end
  end

  context "when whalebrew isn't installed" do
    before do
      allow(Bundle).to receive(:whalebrew_installed?).and_return(false)
    end

    it "successfully installs whalebrew" do
      expect(Bundle).to receive(:system).with("brew", "install", "whalebrew", verbose: false)
                                        .and_return(true)
      expect { do_install }.to raise_error(RuntimeError)
    end
  end

  context "when whalebrew is installed" do
    before do
      allow(Bundle).to receive(:whalebrew_installed?).and_return(true)
      allow(Bundle).to receive(:system).with("whalebrew", "install", "whalebrew/wget", verbose: false)
                                       .and_return(true)
    end

    it "successfully installs an image" do
      expect { do_install }.not_to raise_error
    end

    context "requested image is already installed" do
      before do
        allow(described_class).to receive(:image_installed?).with("whalebrew/wget").and_return(true)
      end

      it "skips" do
        expect(do_install).to be(:skipped)
      end
    end
  end
end
