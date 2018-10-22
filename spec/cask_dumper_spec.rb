# frozen_string_literal: true

require "spec_helper"

describe Bundle::CaskDumper do
  context "when brew-cask is not installed" do
    subject { described_class }

    before do
      described_class.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(false)
    end

    it "returns empty list" do
      expect(subject.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump([])).to eql(["", ""])
    end
  end

  context "when there is no cask" do
    subject { described_class }

    before do
      described_class.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(described_class).to receive(:`).and_return("")
    end

    it "returns empty list" do
      expect(subject.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump([])).to eql(["", ""])
    end
  end

  context "cask `foo`, `bar` and `baz` are installed, while `baz` is required by formula" do
    subject { described_class }

    before do
      described_class.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(described_class).to receive(:`).and_return("foo\nbar\nbaz")
    end

    it "returns list %w[foo bar baz]" do
      expect(subject.casks).to eql(%w[foo bar baz])
    end

    it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'`" do
      expect(subject.dump(%w[baz])).to eql ["cask \"baz\"", "cask \"foo\"\ncask \"bar\""]
    end
  end
end
