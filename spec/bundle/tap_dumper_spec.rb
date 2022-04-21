# frozen_string_literal: true

require "spec_helper"

describe Bundle::TapDumper do
  subject(:dumper) { described_class }

  context "when there is no tap" do
    before do
      described_class.reset!
    end

    it "returns empty list" do
      expect(dumper.tap_names).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump).to eql("")
    end
  end

  context "with `bitbucket/bar`, `homebrew/baz` and `homebrew/foo` taps" do
    before do
      described_class.reset!
      bar = instance_double(Tap, name: "bitbucket/bar", custom_remote?: true,
                            remote: "https://bitbucket.org/bitbucket/bar.git")
      baz = instance_double(Tap, name: "homebrew/baz", custom_remote?: false)
      foo = instance_double(Tap, name: "homebrew/foo", custom_remote?: false)
      allow(Tap).to receive(:each).and_return [bar, baz, foo]
    end

    it "returns list of information" do
      expect(dumper.tap_names).not_to be_empty
    end

    it "dumps output" do
      expect(dumper.dump).to eql \
        "tap \"bitbucket/bar\", \"https://bitbucket.org/bitbucket/bar.git\"\n" \
        "tap \"homebrew/baz\"\ntap \"homebrew/foo\""
    end
  end
end
