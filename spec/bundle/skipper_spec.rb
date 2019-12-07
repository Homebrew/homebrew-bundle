# frozen_string_literal: true

require "spec_helper"

describe Bundle::Skipper do
  subject(:skipper) { described_class }

  before do
    allow(ENV).to receive(:[]).and_return(nil)
    allow(ENV).to receive(:[]).with("HOMEBREW_BUNDLE_BREW_SKIP").and_return("mysql")
    allow(Formatter).to receive(:warning)
    skipper.instance_variable_set(:@skipped_entries, nil)
  end

  describe ".skip?" do
    context "with a listed formula" do
      let(:entry) { Bundle::Dsl::Entry.new(:brew, "mysql") }

      it "returns true" do
        expect(skipper.skip?(entry)).to be true
      end
    end

    context "with an unlisted cask", :needs_macos do
      let(:entry) { Bundle::Dsl::Entry.new(:cask, "java") }

      it "returns false" do
        expect(skipper.skip?(entry)).to be false
      end
    end
  end
end
