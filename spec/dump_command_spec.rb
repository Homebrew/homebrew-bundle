require "spec_helper"

describe Bundle::Commands::Dump do
  context "when files existed" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(ARGV).to receive(:include?).and_return(true)
      allow(ARGV).to receive(:force?).and_return(false)
      allow(ARGV).to receive(:value).and_return(nil)
      allow(Bundle).to receive(:cask_installed?).and_return(true)
    end

    it "raises error" do
      expect do
        Bundle::Commands::Dump.run
      end.to raise_error(RuntimeError)
    end

    it "should exit before doing any work" do
      expect(Bundle::TapDumper).not_to receive(:dump)
      expect(Bundle::BrewDumper).not_to receive(:dump)
      expect(Bundle::CaskDumper).not_to receive(:dump)
      expect do
        Bundle::Commands::Dump.run
      end.to raise_error(RuntimeError)
    end
  end

  context "when files existed and `--force` is passed" do
    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(ARGV).to receive(:force?).and_return(true)
      allow(ARGV).to receive(:value).and_return(nil)
      allow(Bundle).to receive(:cask_installed?).and_return(true)
    end

    it "doesn't raise error" do
      io = double("File", write: true)
      expect_any_instance_of(Pathname).to receive(:open).with("w") { |&block| block.call io }
      expect(io).to receive(:write)
      expect do
        Bundle::Commands::Dump.run
      end.to_not raise_error
    end
  end
end
