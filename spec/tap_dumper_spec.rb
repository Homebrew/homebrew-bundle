require "spec_helper"

describe Bundle::TapDumper do
  context "when there is no tap" do
    before do
      Bundle::TapDumper.reset!
    end
    subject { Bundle::TapDumper }

    it "returns empty list" do
      expect(subject.taps).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "there are tap `homebrew/foo` and `bitbucket/bar`" do
    before do
      Bundle::TapDumper.reset!
      allow(Tap).to receive(:map).and_return [
        {
          "name" => "homebrew/foo",
          "remote" => "https://github.com/Homebrew/homebrew-foo",
          "custom_remote" => false,
        },
        {
          "name" => "bitbucket/bar",
          "remote" => "https://bitbucket.org/bitbucket/bar.git",
          "custom_remote" => true,
        },
      ]
    end
    subject { Bundle::TapDumper }

    it "returns list of information" do
      expect(subject.taps).not_to be_empty
    end

    it "dumps output" do
      expect(subject.dump).to eql("tap \"homebrew/foo\"\ntap \"bitbucket/bar\", \"https://bitbucket.org/bitbucket/bar.git\"")
    end
  end
end
