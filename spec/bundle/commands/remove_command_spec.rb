# frozen_string_literal: true

require "cask/cask_loader"

describe Bundle::Commands::Remove do
  subject(:remove) do
    described_class.run(*args, type:, global:, file:)
  end

  before { File.write(file, content) }
  after { FileUtils.rm_f file }

  let(:global) { false }

  context "when called with a valid formula" do
    let(:args) { ["hello"] }
    let(:type) { :brew }
    let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
    let(:content) do
      <<~BREWFILE
        brew "hello"
      BREWFILE
    end

    it "removes entries from the given Brewfile" do
      expect { remove }.not_to raise_error
      expect(File.read(file)).not_to include("#{type} \"#{args.first}\"")
    end
  end

  context "when called with no type" do
    let(:args) { ["foo"] }
    let(:type) { :none }
    let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }
    let(:content) do
      <<~BREWFILE
        tap "someone/tap"
        brew "foo"
        cask "foo"
      BREWFILE
    end

    it "removes all matching entries from the given Brewfile" do
      expect { remove }.not_to raise_error
      expect(File.read(file)).not_to include(args.first)
    end
  end
end
