# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::Exec do
  context "when a Brewfile is not found" do
    it "raises an error" do
      expect { described_class.run }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      allow(described_class).to receive(:exec).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { described_class.run("bundle", "install") }.not_to raise_error
    end

    it "is able to run without bundle arguments" do
      allow(described_class).to receive(:exec).with("bundle", "install").and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { described_class.run("bundle", "install") }.not_to raise_error
    end

    it "raises an exception if called without a command" do
      allow(described_class).to receive(:exec).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { described_class.run }.to raise_error(RuntimeError)
    end

    it "raises if called with a command that's not on the PATH" do
      allow(described_class).to receive_messages(exec: nil, which: nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { described_class.run("bundle", "install") }.to raise_error(RuntimeError)
    end

    it "prepends the path of the requested command to PATH before running" do
      expect(described_class).to receive(:exec).with("bundle", "install").and_return(nil)
      expect(described_class).to receive(:which).and_return(Pathname("/usr/local/bin/bundle"))
      allow(ENV).to receive(:prepend_path).with(any_args).and_call_original
      expect(ENV).to receive(:prepend_path).with("PATH", "/usr/local/bin").once.and_call_original
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")
      described_class.run("bundle", "install")
    end

    describe "when running a command which exists but is not on the PATH" do
      it "does not raise if the command is a relative path with current directory indicator" do
        allow(described_class).to receive(:exec).with("./configure").and_return(nil)
        expect(described_class).not_to receive(:which)
        allow_any_instance_of(Pathname).to receive(:read)
          .and_return("brew 'zlib'")

        expect { described_class.run("./configure") }.not_to raise_error
      end

      it "does not raise if the command is a relative path without current directory indicator" do
        allow(described_class).to receive(:exec).with("bin/install").and_return(nil)
        expect(described_class).not_to receive(:which)
        allow_any_instance_of(Pathname).to receive(:read)
          .and_return("brew 'zlib'")

        expect { described_class.run("bin/install") }.not_to raise_error
      end

      it "does not raise if the command is an absolute path" do
        allow(described_class).to receive(:exec).with("/Users/admin/Downloads/command").and_return(nil)
        expect(described_class).not_to receive(:which)
        allow_any_instance_of(Pathname).to receive(:read)
          .and_return("brew 'zlib'")

        expect { described_class.run("/Users/admin/Downloads/command") }.not_to raise_error
      end
    end
  end
end
