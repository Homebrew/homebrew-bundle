# frozen_string_literal: true

require "spec_helper"

describe Bundle::WhalebrewDumper do
  subject(:dumper) { described_class }

  context "when whalebrew is not installed" do
    before do
      described_class.reset!
      allow(Bundle).to receive(:whalebrew_installed?).and_return(false)
    end

    it "returns empty list" do
      expect(dumper.images).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump).to eql("")
    end
  end

  context "when whalebrew is installed" do
    before do
      allow(Bundle).to receive(:whalebrew_installed?).and_return(true)
      allow(described_class).to receive(:images).and_return(["whalebrew/wget", "whalebrew/dig"])
    end

    context "images are installed" do
      it "returns correct listing" do
        expect(dumper.images).to eq(["whalebrew/wget", "whalebrew/dig"])
      end

      it "dumps usable output for Brewfile" do
        expect(dumper.dump).to eql([%Q{whalebrew "whalebrew/wget"\nwhalebrew "whalebrew/dig"}])
      end
    end
  end
end
