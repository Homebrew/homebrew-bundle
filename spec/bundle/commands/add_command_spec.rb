# frozen_string_literal: true

describe Bundle::Commands::Add do
  subject(:add) do
    described_class.run(*args, type:, global:, file:)
  end

  let(:args) { ["hello"] }
  let(:type) { :brew }
  let(:global) { false }
  let(:file) { "/tmp/some_random_brewfile#{Random.rand(2 ** 16)}" }

  context "when called with valid arguments" do
    before { FileUtils.touch file }
    after { FileUtils.rm_f file }

    it "adds entries to the given Brewfile" do
      expect { add }.not_to raise_error
      expect(File.read(file)).to include("brew \"#{args.first}\"")
    end
  end
end
