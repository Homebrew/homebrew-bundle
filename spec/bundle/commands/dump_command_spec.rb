# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::Dump do
  context "when files existed" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(Bundle).to receive(:cask_installed?).and_return(true)
    end

    it "raises error" do
      expect do
        described_class.run
      end.to raise_error(RuntimeError)
    end

    it "exits before doing any work" do
      expect(Bundle::TapDumper).not_to receive(:dump)
      expect(Bundle::BrewDumper).not_to receive(:dump)
      expect(Bundle::CaskDumper).not_to receive(:dump)
      expect(Bundle::WhalebrewDumper).not_to receive(:dump)
      expect do
        described_class.run
      end.to raise_error(RuntimeError)
    end
  end

  context "when files existed and `--force` is passed" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(Bundle).to receive(:cask_installed?).and_return(true)
    end

    it "doesn't raise error" do
      io = instance_double("File", write: true)
      expect_any_instance_of(Pathname).to receive(:open).with("w").and_yield(io)
      expect(io).to receive(:write)
      expect do
        described_class.run(force: true, global: true)
      end.not_to raise_error
    end
  end
end
