# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::Init do
  context "when a Brewfile is found" do
    it "raise an error" do
      allow(Bundle).to receive(:should_not_write_file?).and_return(true)
      expect{ Bundle::Commands::Init.run }.to raise_error
    end
  end

  context "when a Brewfile is not found" do
    before do
      allow(ARGV).to receive(:value).and_return(nil)
      allow(ARGV).to receive(:force?).and_return(false)
    end

    it "generates template" do
      expect( Bundle ).to receive(:write_file) do |file, content, _overwrite|
        expect(file).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
        expect(content).to include("# cask \"google-chrome\"\n")
      end
      Bundle::Commands::Init.run
    end

    it "doesn't raise an error" do
      io = double("File", write: true)
      expect_any_instance_of(Pathname).to receive(:open).with("w") { |&block| block.call io }
      expect(io).to receive(:write)
      expect do
        Bundle::Commands::Init.run
      end.to_not raise_error
    end
  end
end
