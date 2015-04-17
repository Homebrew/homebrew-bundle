require "spec_helper"

describe Bundle::RepoDumper do
  context "when brew is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(false)
      expect { Bundle::RepoDumper.new }.to raise_error
    end
  end

  context "when there is no tap" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::RepoDumper).to receive(:`).and_return("")
    end
    subject { Bundle::RepoDumper.new }

    it "return empty list" do
      expect(subject.repos).to be_empty
    end

    it "dump as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "there are tap `foo` and `bar`" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::RepoDumper).to receive(:`).and_return("foo\nbar")
    end
    subject { Bundle::RepoDumper.new }

    it "return list %w[foo bar]" do
      expect(subject.repos).to eql(%w[foo bar])
    end

    it "dump as `tap 'foo' tap 'bar'`" do
      expect(subject.to_s).to eql("tap 'foo'\ntap 'bar'")
    end
  end
end
