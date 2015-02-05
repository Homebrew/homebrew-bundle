require "spec_helper"


describe Brewdler::Dumper do
  before do
    allow(Brewdler).to receive(:brew_installed?).and_return(true)
    allow(Brewdler).to receive(:cask_installed?).and_return(true)
    allow(ARGV).to receive(:force?).and_return(false)
    allow_any_instance_of(Brewdler::BrewDumper).to receive(:`).and_return("[]")
    allow_any_instance_of(Brewdler::RepoDumper).to receive(:`).and_return("caskroom/cask")
    allow_any_instance_of(Brewdler::CaskDumper).to receive(:`).and_return("google-chrome\njava")
  end
  subject { Brewdler::Dumper.new }

  it "generate output" do
    expect(subject).to receive(:write_file) do |file, content, overwrite|
      expect(content).to eql("tap 'caskroom/cask'\ncask 'google-chrome'\ncask 'java'\n")
    end
    subject.dump_brewfile
  end
end
