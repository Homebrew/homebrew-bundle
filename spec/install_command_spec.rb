require 'spec_helper'

describe Brewdler::Commands::Install do
  context "when a Brewfile is not found" do
    it "raises an error" do
      expect { Brewdler::Commands::Install.run }.to raise_error
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      File.stub(:read).and_return("brew 'git'\ncask 'google-chrome'")
      expect { Brewdler::Commands::Install.run }.to_not raise_error('No Brewfile found.')

      File.stub(read: 'git', open: ['git'])
      expect { Brewdler::Commands::Install.run }.to_not raise_error('No Brewfile found.')
    end
  end
end
