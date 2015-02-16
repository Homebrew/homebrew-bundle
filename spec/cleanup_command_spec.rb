require "spec_helper"

describe Brewdler::Commands::Cleanup do
  context "read Brewfile and currently installation" do
    before do
      allow(File).to receive(:read).and_return("brew 'a'\nbrew 'b'")
      allow(Brewdler::Commands::Cleanup).to receive(:`).and_return("a\nc\nd")
    end

    it "computes which formulae to uninstall" do
      expect(Brewdler::Commands::Cleanup.formulae_to_uninstall).to eql(%w[c d])
    end
  end

  context "no formulae to uninstall" do
    before do
      allow(Brewdler::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return([])
    end

    it "does nothing" do
      expect(ARGV).not_to receive(:dry_run?)
      expect(Kernel).not_to receive(:system)
      Brewdler::Commands::Cleanup.run
    end
  end

  context "there are formulae to uninstall" do
    before do
      allow(Brewdler::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return(%w[a b])
      allow(ARGV).to receive(:dry_run?).and_return(false)
    end

    it "uninstalls formulae" do
      expect(Kernel).to receive(:system).with(*%w[brew uninstall --force a b])
      expect { Brewdler::Commands::Cleanup.run }.to output(/Uninstalled 2 formulae/).to_stdout
    end
  end

  context "there are formulae to uninstall but passing with `--dry-run`" do
    before do
      allow(Brewdler::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return(%w[a b])
      allow(ARGV).to receive(:dry_run?).and_return(true)
    end

    it "lists formulae" do
      expect(Brewdler::Commands::Cleanup).to receive(:puts_columns).with(%w[a b])
      expect(Kernel).not_to receive(:system)
      expect { Brewdler::Commands::Cleanup.run }.to output(/Would uninstall:/).to_stdout
    end
  end
end
