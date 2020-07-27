# frozen_string_literal: true

require "spec_helper"

describe Bundle::Locker do
  subject(:locker) { described_class }

  describe ".lockfile" do
    it "returns a Pathname" do
      allow(Bundle::Brewfile).to receive(:path).and_return(Pathname("Brewfile"))
      expect(locker.lockfile.class).to be Pathname
    end

    it "correctly matches the Brewfile name in the lockfile name" do
      allow(Bundle::Brewfile).to receive(:path).and_return(Pathname("Personal.brewfile"))
      expect(locker.lockfile).to eq Pathname.new("Personal.brewfile.lock.json")
    end
  end

  describe ".write_lockfile?" do
    it "returns false if `no_lock` is true" do
      expect(locker.write_lockfile?(no_lock: true)).to be false
    end

    it "returns false if HOMEBREW_BUNDLE_NO_LOCK is set" do
      ENV["HOMEBREW_BUNDLE_NO_LOCK"] = "1"
      expect(locker.write_lockfile?).to be false
    end

    it "returns false if it would write to /dev" do
      allow(Bundle::Brewfile).to receive(:path).and_return(Pathname("/dev/stdin"))
      expect(locker.write_lockfile?).to be false
    end

    it "returns true otherwise" do
      ENV["HOMEBREW_BUNDLE_NO_LOCK"] = nil
      allow(Bundle::Brewfile).to receive(:path).and_return(Pathname("Brewfile"))
      expect(locker.write_lockfile?).to be true
    end
  end

  describe ".whalebrew_list" do
    before do
      allow(Bundle::WhalebrewDumper).to receive(:images).and_return(["whalebrew/wget"])
      allow(locker).to receive(:`)
        .with("docker image inspect whalebrew/wget --format '{{ index .RepoDigests 0 }}'")
        .and_return("whalebrew/wget@sha256:abcd1234")
    end

    it "returns a hash of the name and layer checksum" do
      expect(locker.whalebrew_list).to eq({ "whalebrew/wget" => "abcd1234" })
    end
  end

  describe ".lock" do
    context "writes Brewfile.lock.json" do
      let(:lockfile) { Pathname("Brewfile.json.lock") }
      let(:brew_options) { { restart_service: true } }
      let(:entries) do
        [
          Bundle::Dsl::Entry.new(:brew, "mysql", brew_options),
          Bundle::Dsl::Entry.new(:cask, "adoptopenjdk8"),
          Bundle::Dsl::Entry.new(:mas, "Xcode", id: 497_799_835),
          Bundle::Dsl::Entry.new(:tap, "homebrew/homebrew-cask-versions"),
          Bundle::Dsl::Entry.new(:whalebrew, "whalebrew/wget"),
        ]
      end

      before do
        allow(locker).to receive(:lockfile).and_return(lockfile)
        allow(brew_options).to receive(:deep_stringify_keys)
          .and_return("restart_service" => true)
        allow(locker).to receive(:`).with("brew info --json=v1 --installed").and_return <<~EOS
          [
            {
              "name":"mysql",
              "bottle":{
                "stable":{}
              }
            }
          ]
        EOS
        allow(locker).to receive(:`).with("brew list --versions").and_return("mysql 8.0.18")
        allow(locker).to receive(:`).with("whalebrew list").and_return("COMMAND   IMAGE\nwget      whalebrew/wget")
        allow(locker).to receive(:`)
          .with("docker image inspect whalebrew/wget --format '{{ index .RepoDigests 0 }}'")
          .and_return("whalebrew/wget@sha256:abcd1234")
        allow(Bundle::WhalebrewDumper).to receive(:images).and_return(["whalebrew/wget"])
      end

      context "on macOS" do
        before do
          allow(OS).to receive(:mac?).and_return(true)

          allow(locker).to receive(:`).with("brew cask list --versions").and_return("adoptopenjdk8 8,232:b09")
          allow(locker).to receive(:`).with("mas list").and_return("497799835 Xcode (11.2)")
        end

        it "returns true" do
          expect(lockfile).to receive(:write)
          expect(locker.lock(entries)).to be true
        end

        it "returns false on a permission error" do
          expect(lockfile).to receive(:write).and_raise(Errno::EPERM)
          expect(locker).to receive(:opoo)
          expect(locker.lock(entries)).to be false
        end
      end

      context "on Linux" do
        before do
          allow(OS).to receive(:mac?).and_return(false)
          allow(OS).to receive(:linux?).and_return(true)
        end

        it "returns true" do
          expect(lockfile).to receive(:write)
          expect(locker.lock(entries)).to be true
        end
      end
    end
  end
end
