require "spec_helper"


describe Bundle::Dumper do
  before do
    allow(Bundle).to receive(:brew_installed?).and_return(true)
    allow(Bundle).to receive(:cask_installed?).and_return(true)
    allow(ARGV).to receive(:force?).and_return(false)
    allow(ARGV).to receive(:value).and_return(nil)
    allow_any_instance_of(Bundle::BrewDumper).to receive(:`).and_return("[]")
    allow_any_instance_of(Bundle::RepoDumper).to receive(:`).and_return("caskroom/cask")
    allow_any_instance_of(Bundle::CaskDumper).to receive(:`).and_return("google-chrome\njava")
  end
  subject { Bundle::Dumper.new }

  it "generate output" do
    expect(subject).to receive(:write_file) do |file, content, overwrite|
      expect(file).to eql(Pathname.new(Dir.pwd).join("Brewfile"))
      expect(content).to eql("tap 'caskroom/cask'\ncask 'google-chrome'\ncask 'java'\n")
    end
    subject.dump_brewfile
  end
end
