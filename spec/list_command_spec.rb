# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::List do
  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  context "outputs dependencies to stdout" do
    before do
      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("tap 'phinze/cask'\nbrew 'mysql', conflicts_with: ['mysql56']\ncask 'google-chrome'\nmas '1Password', id: 443987910")
    end
    it "only shows brew deps when no options are passed" do
      allow(ARGV).to receive(:value).and_return(nil)
      expect { Bundle::Commands::List.run }.to output("mysql\n").to_stdout
    end
    it "only shows brew deps when --brews is passed" do
      ARGV << "--brews"
      expect { Bundle::Commands::List.run }.to output("mysql\n").to_stdout
    end
    it "only shows cask deps when --casks is passed" do
      ARGV << "--casks"
      expect { Bundle::Commands::List.run }.to output("google-chrome\n").to_stdout
    end
    it "only shows taps when --taps is passed" do
      ARGV << "--taps"
      expect { Bundle::Commands::List.run }.to output("phinze/cask\n").to_stdout
    end
    it "only shows mas when --mas is passed" do
      ARGV << "--mas"
      expect { Bundle::Commands::List.run }.to output("1Password\n").to_stdout
    end
    after(:example) do
      ["--taps", "--mas", "--brews", "--casks"].each do |option|
        ARGV.delete option if ARGV.include? option
      end
    end
  end
end
