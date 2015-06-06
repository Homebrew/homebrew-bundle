require "spec_helper"

describe Bundle::CaskDumper do
  context "when brew-cask is not installed" do
    before { allow(Bundle).to receive(:cask_installed?).and_return(false) }
    subject { Bundle::CaskDumper.new }

    it "returns empty list" do
      expect(subject.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump_to_string []).to eql(["", ""])
    end
  end

  context "when there is no cask" do
    before do
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:`).and_return("")
    end
    subject { Bundle::CaskDumper.new }

    it "returns empty list" do
      expect(subject.casks).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump_to_string []).to eql(["", ""])
    end
  end

  context "cask `foo`, `bar` and `baz` are installed, while `baz` is required by formula" do
    before do
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:`).and_return("foo\nbar\nbaz")
    end
    subject { Bundle::CaskDumper.new }

    it "returns list %w[foo bar baz]" do
      expect(subject.casks).to eql(%w[foo bar baz])
    end

    it "dumps as `cask 'baz'` and `cask 'foo' cask 'bar'`" do
      expect(subject.dump_to_string %w[baz]).to eql ["cask 'baz'", "cask 'foo'\ncask 'bar'"]
    end
  end
end
