# frozen_string_literal: true

require "spec_helper"

describe Bundle::TapDumper do
  subject(:dumper) { described_class }

  context "when there is no tap" do
    before do
      described_class.reset!
    end

    it "returns empty list" do
      expect(dumper.taps).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump).to eql("")
    end
  end

  context "there are tap `bitbucket/bar`, `homebrew/baz` and `homebrew/foo`" do
    before do
      described_class.reset!
      allow(Tap).to receive(:map).and_return [
        {
          "name"          => "bitbucket/bar",
          "remote"        => "https://bitbucket.org/bitbucket/bar.git",
          "custom_remote" => true,
        },
        {
          "name"          => "homebrew/baz",
          "remote"        => "https://github.com/Homebrew/homebrew-baz",
          "custom_remote" => false,
        },
        {
          "name"          => "homebrew/foo",
          "remote"        => "https://github.com/Homebrew/homebrew-foo",
          "custom_remote" => false,
          "pinned"        => true,
        },
      ]
    end

    it "returns list of information" do
      expect(dumper.taps).not_to be_empty
    end

    it "dumps output" do
      expect(dumper.dump).to eql \
        "tap \"bitbucket/bar\", \"https://bitbucket.org/bitbucket/bar.git\"\n" \
        "tap \"homebrew/baz\"\ntap \"homebrew/foo\", pin: true"
    end
  end
end
