require "spec_helper"

describe Brewdler::CaskDumper do
  context "when brew-cask is not installed" do
    before { allow(Brewdler).to receive(:cask_installed?).and_return(false) }
    subject { Brewdler::CaskDumper.new }

    it "return empty list" do
      expect(subject.casks).to be_empty
    end

    it "dump as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "when there is no cask" do
    before do
      allow(Brewdler).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Brewdler::CaskDumper).to receive(:`).and_return("")
    end
    subject { Brewdler::CaskDumper.new }

    it "return empty list" do
      expect(subject.casks).to be_empty
    end

    it "dump as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "cask `foo` and `bar` are installed" do
    before do
      allow(Brewdler).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Brewdler::CaskDumper).to receive(:`).and_return("foo\nbar")
    end
    subject { Brewdler::CaskDumper.new }

    it "return list %w[foo bar]" do
      expect(subject.casks).to eql(%w[foo bar])
    end

    it "dump as `cask 'foo' cask 'bar'`" do
      expect(subject.to_s).to eql("cask 'foo'\ncask 'bar'")
    end
  end
end
