# frozen_string_literal: true

require "spec_helper"
require "cask"

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

    chrome     = instance_double(Cask::Cask,
                                 full_name: "google-chrome",
                                 to_s:      "google-chrome",
                                 config:    nil)
    java       = instance_double(Cask::Cask,
                                 full_name: "java",
                                 to_s:      "java",
                                 config:    nil)
    iterm2beta = instance_double(Cask::Cask,
                                 full_name: "homebrew/cask-versions/iterm2-beta",
                                 to_s:      "iterm2-beta",
                                 config:    nil)

    allow(Cask::Caskroom).to receive(:casks).and_return([chrome, java, iterm2beta])
  end

  it "generates output" do
    expect(dumper.build_brewfile).to eql("cask \"google-chrome\"\ncask \"java\"\ncask \"iterm2-beta\"\n")
  end

  it "determines the brewfile correctly" do
    expect(dumper.brewfile_path).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
  end
end
