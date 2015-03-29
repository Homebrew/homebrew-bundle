require "spec_helper"

describe Brewdler::Commands::Dump do
  context "when files existed" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(ARGV).to receive(:force?).and_return(false)
      allow(ARGV).to receive(:value).and_return(nil)
    end

    it "raises error" do
      expect do
        Bundler.with_clean_env { Brewdler::Commands::Dump.run }
      end.to raise_error
    end
  end

  context "when files existed and `--force` is passed" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:file?).and_return(true)
      allow(ARGV).to receive(:force?).and_return(true)
      allow(ARGV).to receive(:value).and_return(nil)
    end

    it "doesn't raise error" do
      expect(FileUtils).to receive(:rm)
      expect_any_instance_of(Pathname).to receive(:write)
      expect do
        Bundler.with_clean_env { Brewdler::Commands::Dump.run }
      end.to_not raise_error
    end
  end
end
