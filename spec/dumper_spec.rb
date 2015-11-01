require "spec_helper"

describe Bundle::Dumper do
  before do
    allow(Bundle).to receive(:brew_installed?).and_return(true)
    allow(Bundle).to receive(:cask_installed?).and_return(true)
    allow(ARGV).to receive(:force?).and_return(false)
    allow(ARGV).to receive(:value).and_return(nil)
    Bundle::BrewDumper.formulae_info_reset!
    allow(Bundle::BrewDumper).to receive(:`).and_return("[]")
    allow_any_instance_of(Bundle::TapDumper).to receive(:`).and_return("[]")
    allow_any_instance_of(Bundle::CaskDumper).to receive(:`).and_return("google-chrome\njava")
  end
  subject { Bundle::Dumper.new }

  it "generates output" do
    expect(subject).to receive(:write_file) do |file, content, _overwrite|
      expect(file).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
      expect(content).to eql("cask 'google-chrome'\ncask 'java'\n")
    end
    subject.dump_brewfile
  end
end
