# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::Add do
  context "when a Brewfile is not found" do
    it "raises an error" do
      expect { described_class.run("wget") }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    before do
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")
    end

    context "when no arguments are passed" do
      it "raises an error" do
        expect { described_class.run }.to raise_error(UsageError)
      end
    end

    context "the formula is not in the Brewfile" do
      it "does not raise an error" do
        expect { described_class.run("wget") }.to_not raise_error
      end

      it "adds the formula to the Brewfile" do
        #TODO
      end
    end

    context "the formula is in the Brewfile" do
      before do
        allow_any_instance_of(Pathname).to receive(:read)
          .and_return("brew 'openssl'\nbrew 'wget'")
      end

      it "raises an error" do
        expect { described_class.run("wget") }.to raise_error(RuntimeError)
      end
    end
  end
end
