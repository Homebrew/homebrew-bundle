# frozen_string_literal: true

require "spec_helper"

describe Bundle do
  context "system call succeed" do
    it "omits all stdout output if verbose is false" do
      expect { described_class.system "echo", "foo", verbose: false }.not_to output.to_stdout_from_any_process
    end

    it "emits all stdout output if verbose is true" do
      expect { described_class.system "echo", "foo", verbose: true }.to output("foo\n").to_stdout_from_any_process
    end
  end

  context "system call failed" do
    before do
      allow_any_instance_of(Process::Status).to receive(:success?).and_return(false)
    end

    it "emits all stdout output even if verbose is false" do
      expect { described_class.system "echo", "foo", verbose: false }.to output("foo\n").to_stdout_from_any_process
    end

    it "emits all stdout output only once if verbose is true" do
      expect { described_class.system "echo", "foo", verbose: true }.to output("foo\n").to_stdout_from_any_process
    end
  end

  context "check for brew cask", :needs_macos do
    it "finds it when present" do
      allow(File).to receive(:directory?).with("#{HOMEBREW_PREFIX}/Caskroom").and_return(true)
      allow(File).to receive(:directory?)
        .with("#{HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-cask")
        .and_return(true)
      expect(described_class.cask_installed?).to be(true)
    end
  end

  context "check for brew services", :needs_macos do
    it "finds it when present" do
      allow(described_class).to receive(:which).and_return(true)
      expect(described_class.services_installed?).to be(true)
    end
  end

  context "check for mas", :needs_macos do
    it "finds it when present" do
      allow(described_class).to receive(:which).and_return(true)
      expect(described_class.mas_installed?).to be(true)
    end
  end
end
