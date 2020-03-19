# frozen_string_literal: true

require "spec_helper"

describe Bundle::Dumper do
  subject(:dumper) { described_class }

  before do
    allow(Bundle).to receive(:cask_installed?).and_return(true)
    allow(Bundle).to receive(:mas_installed?).and_return(false)
    allow(Bundle).to receive(:whalebrew_installed?).and_return(false)
    Bundle::BrewDumper.reset!
    Bundle::TapDumper.reset!
    Bundle::CaskDumper.reset!
    Bundle::MacAppStoreDumper.reset!
    Bundle::WhalebrewDumper.reset!
    Bundle::BrewServices.reset!
    allow(Bundle::CaskDumper).to receive(:`).and_return("google-chrome\njava")
  end

  it "generates output" do
    expect(dumper.build_brewfile).to eql("cask \"google-chrome\"\ncask \"java\"\n")
  end

  it "determines the brewfile correctly" do
    expect(dumper.brewfile_path).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
  end
end
