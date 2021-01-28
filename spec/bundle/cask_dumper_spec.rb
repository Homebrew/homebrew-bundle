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
      expect(dumper.cask_list).to be_empty
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
      expect(dumper.cask_list).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump([])).to eql(["", ""])
    end
  end

  context "when casks `foo`, `bar` and `baz` are installed, with `baz` being a formula requirement" do
    before do
      described_class.reset!

      foo = instance_double("Cask::Cask", to_s: "foo", desc: nil, config: nil)
      baz = instance_double("Cask::Cask", to_s: "baz", desc: "Software", config: nil)
      bar = instance_double("Cask::Cask", to_s:   "bar",
                                          desc:   nil,
                                          config: instance_double("Cask::Cask.config",
                                                                  explicit: {
                                                                    fontdir:   "/Library/Fonts",
                                                                    languages: ["zh-TW"],
                                                                  }))

      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(Cask::Caskroom).to receive(:casks).and_return([foo, bar, baz])
      allow(described_class).to receive(:`).and_return("foo\nbar\nbaz")
    end

    it "returns list %w[foo bar baz]" do
      expect(dumper.cask_list).to eql(%w[foo bar baz])
    end

    it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'` plus descriptions and config values" do
      expect(dumper.dump(%w[baz], describe: true)).to eql [
        "# Software\ncask \"baz\"",
        "cask \"foo\"\ncask \"bar\", args: { fontdir: \"/Library/Fonts\", language: \"zh-TW\" }",
      ]
    end
  end

  describe "#formula_dependencies" do
    context "when the given casks don't have formula dependencies" do
      before do
        allow(described_class)
          .to receive(:`)
          .and_return("{\"formulae\":[],\"casks\":[]")
      end

      it "returns an empty array" do
        expect(dumper.formula_dependencies(["foo"])).to eql([])
      end
    end

    context "when cask info returns invalid JSON" do
      before do
        allow(described_class)
          .to receive(:`)
          .and_return("Error: something from cask!")
      end

      it "returns an empty array" do
        expect(dumper.formula_dependencies(["foo"])).to eql([])
      end
    end

    context "when multiple casks have the same dependency" do
      let(:json_output) do
        "{" \
        "\"formulae\":[]," \
        "\"casks\":[{\"depends_on\":{\"formula\":[\"baz\",\"qux\"]}},{\"depends_on\":{\"formula\":[\"baz\"]}}]" \
        "}"
      end

      before do
        allow(described_class)
          .to receive(:`)
          .and_return(json_output)
      end

      it "returns an array of unique formula dependencies" do
        expect(dumper.formula_dependencies(["foo", "bar"])).to eql(["baz", "qux"])
      end
    end
  end
end
