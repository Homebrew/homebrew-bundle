require "spec_helper"

describe Bundle::CaskDumper do
  context "when brew-cask is not installed" do
    before do
      Bundle::CaskDumper.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(false)
    end
    subject { Bundle::CaskDumper }

    it "returns empty list" do
      expect(subject.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump([])).to eql(["", ""])
    end
  end

  context "when there is no cask" do
    before do
      Bundle::CaskDumper.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(Bundle::CaskDumper).to receive(:`).and_return("")
    end
    subject { Bundle::CaskDumper }

    it "returns empty list" do
      expect(subject.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump([])).to eql(["", ""])
    end
  end

  context "cask `foo`, `bar` and `baz` are installed, while `baz` is required by formula" do
    before do
      Bundle::CaskDumper.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(Bundle::CaskDumper).to receive(:`).and_return("foo\nbar\nbaz")
    end
    subject { Bundle::CaskDumper }

    it "returns list %w[foo bar baz]" do
      expect(subject.casks).to eql(%w[foo bar baz])
    end

    it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'`" do
      expect(subject.dump(%w[baz])).to eql ["cask \"baz\"", "cask \"foo\"\ncask \"bar\""]
    end
  end
end
