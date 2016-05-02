require "spec_helper"

describe Bundle::MacAppStoreDumper do
  context "when mas is not installed" do
    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(false)
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns empty list" do
      expect(subject.apps).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "when there is no apps" do
    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(Bundle::MacAppStoreDumper).to receive(:`).and_return("")
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns empty list" do
      expect(subject.apps).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "apps `foo`, `bar` and `baz` are installed" do
    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(Bundle::MacAppStoreDumper).to receive(:`).and_return("foo 123\nbar 456\nbaz 789")
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns list %w[foo bar baz]" do
      expect(subject.apps).to eql([["foo", "123"], ["bar", "456"], ["baz", "789"]])
    end
  end
end
