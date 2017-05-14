require "spec_helper"

describe Bundle::Dumper do
  before do
    allow(Bundle).to receive(:cask_installed?).and_return(true)
    allow(Bundle).to receive(:mas_installed?).and_return(false)
    allow(ARGV).to receive(:force?).and_return(false)
    allow(ARGV).to receive(:value).and_return(nil)
    Bundle::BrewDumper.reset!
    Bundle::TapDumper.reset!
    Bundle::CaskDumper.reset!
    Bundle::MacAppStoreDumper.reset!
    Bundle::BrewServices.reset!
    allow(Bundle::CaskDumper).to receive(:`).and_return("google-chrome\njava")
  end
  subject { Bundle::Dumper }

  it "generates output" do
    expect(subject).to receive(:write_file) do |file, content, _overwrite|
      expect(file).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
      expect(content).to eql("cask \"google-chrome\"\ncask \"java\"\n")
    end
    subject.dump_brewfile
  end
end
