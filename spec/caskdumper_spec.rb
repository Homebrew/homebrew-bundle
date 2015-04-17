require "spec_helper"

describe Bundle::CaskDumper do
  context "when brew-cask is not installed" do
    before { allow(Bundle).to receive(:cask_installed?).and_return(false) }
    subject { Bundle::CaskDumper.new }

    it "return empty list" do
      expect(subject.casks).to be_empty
    end

    it "dump as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "when there is no cask" do
    before do
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:`).and_return("")
    end
    subject { Bundle::CaskDumper.new }

    it "return empty list" do
      expect(subject.casks).to be_empty
    end

    it "dump as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "cask `foo` and `bar` are installed" do
    before do
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Bundle::CaskDumper).to receive(:`).and_return("foo\nbar")
    end
    subject { Bundle::CaskDumper.new }

    it "return list %w[foo bar]" do
      expect(subject.casks).to eql(%w[foo bar])
    end

    it "dump as `cask 'foo' cask 'bar'`" do
      expect(subject.to_s).to eql("cask 'foo'\ncask 'bar'")
    end
  end
end
