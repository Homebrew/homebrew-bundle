# frozen_string_literal: true

require "spec_helper"

describe Bundle::CaskDumper do
  subject(:dumper) { described_class }

  context "when brew-cask is not installed" do
    before do
      described_class.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(false)
    end

    it "returns empty list" do
      expect(dumper.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump([])).to eql(["", ""])
    end
  end

  context "when there is no cask" do
    before do
      described_class.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(described_class).to receive(:`).and_return("")
    end

    it "returns empty list" do
      expect(dumper.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump([])).to eql(["", ""])
    end
  end

  context "cask `foo`, `bar` and `baz` are installed, while `baz` is required by formula" do
    before do
      described_class.reset!
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(described_class).to receive(:`).and_return("foo\nbar\nbaz")
    end

    it "returns list %w[foo bar baz]" do
      expect(dumper.casks).to eql(%w[foo bar baz])
    end

    it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'`" do
      expect(dumper.dump(%w[baz])).to eql ["cask \"baz\"", "cask \"foo\"\ncask \"bar\""]
    end
  end

  describe "#formula_dependencies" do
    context "when the given casks don't have formula dependencies" do
      before do
        allow(described_class)
          .to receive(:`)
          .with("brew cask info foo --json=v1")
          .and_return("[{\"depends_on\":{}}]")
      end

      it "returns an empty array" do
        expect(dumper.formula_dependencies(["foo"])).to eql([])
      end
    end

    context "when cask info returns invalid JSON" do
      before do
        allow(described_class)
          .to receive(:`)
          .with("brew cask info foo --json=v1")
          .and_return("Error: somethng from cask!")
      end

      it "returns an empty array" do
        expect(dumper.formula_dependencies(["foo"])).to eql([])
      end
    end

    context "when multiple casks have the same dependency" do
      before do
        allow(described_class)
          .to receive(:`)
          .with("brew cask info foo bar --json=v1")
          .and_return("[{\"depends_on\":{\"formula\":[\"baz\",\"qux\"]}},{\"depends_on\":{\"formula\":[\"baz\"]}}]")
      end

      it "returns an array of unique formula dependencies" do
        expect(dumper.formula_dependencies(["foo", "bar"])).to eql(["baz", "qux"])
      end
    end
  end
end
