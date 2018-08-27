# frozen_string_literal: true

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

  context "there are tap `bitbucket/bar`, `homebrew/baz` and `homebrew/foo`" do
    before do
      Bundle::TapDumper.reset!
      allow(Tap).to receive(:map).and_return [
        {
          "name" => "bitbucket/bar",
          "remote" => "https://bitbucket.org/bitbucket/bar.git",
          "custom_remote" => true,
        },
        {
          "name" => "homebrew/baz",
          "remote" => "https://github.com/Homebrew/homebrew-baz",
          "custom_remote" => false,
        },
        {
          "name" => "homebrew/foo",
          "remote" => "https://github.com/Homebrew/homebrew-foo",
          "custom_remote" => false,
          "pinned" => true,
        },
      ]
    end
    subject { Bundle::TapDumper }

    it "returns list of information" do
      expect(subject.taps).not_to be_empty
    end

    it "dumps output" do
      expect(subject.dump).to eql("tap \"bitbucket/bar\", \"https://bitbucket.org/bitbucket/bar.git\"\ntap \"homebrew/baz\"\ntap \"homebrew/foo\", pin: true")
    end
  end
end
