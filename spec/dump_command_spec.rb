require "spec_helper"

describe Brewdler::Commands::Dump do
  context "when files existed" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow(Brewdler).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(ARGV).to receive(:force?).and_return(false)
    end

    it "raises error" do
      expect { Brewdler::Commands::Dump.run }.to raise_error
    end
  end

  context "when files existed and `--force` is passed" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow(Brewdler).to receive(:cask_installed?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:file?).and_return(true)
      allow(ARGV).to receive(:force?).and_return(true)
    end

    it "doesn't raise error" do
      expect(FileUtils).to receive(:rm)
      expect_any_instance_of(Pathname).to receive(:write)
      expect { Brewdler::Commands::Dump.run }.to_not raise_error
    end
  end
end
