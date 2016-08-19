require "spec_helper"

describe Bundle do
  context "system call succeed" do
    it "omits all stdout output if ARGV.verbose? is false" do
      allow(ARGV).to receive(:verbose?).and_return(false)
      expect { Bundle.system "echo", "foo" }.to_not output.to_stdout_from_any_process
    end

    it "emits all stdout output if ARGV.verbose? is true" do
      allow(ARGV).to receive(:verbose?).and_return(true)
      expect { Bundle.system "echo", "foo" }.to output("foo\n").to_stdout_from_any_process
    end
  end

  context "system call failed" do
    before do
      allow_any_instance_of(Process::Status).to receive(:success?).and_return(false)
    end

    it "emits all stdout output even if ARGV.verbose? is false" do
      allow(ARGV).to receive(:verbose?).and_return(false)
      expect { Bundle.system "echo", "foo" }.to output("foo\n").to_stdout_from_any_process
    end

    it "emits all stdout output only once if ARGV.verbose? is true" do
      allow(ARGV).to receive(:verbose?).and_return(true)
      expect { Bundle.system "echo", "foo" }.to output("foo\n").to_stdout_from_any_process
    end
  end

  context "check for brew cask" do
    it "finds it when present" do
      allow(Bundle).to receive(:which).and_return(true)
      expect(Bundle.cask_installed?).to eql(true)
    end
  end

  context "check for brew services" do
    it "finds it when present" do
      allow(Bundle).to receive(:which).and_return(true)
      expect(Bundle.services_installed?).to eql(true)
    end
  end

  context "check for mas" do
    it "finds it when present" do
      allow(Bundle).to receive(:which).and_return(true)
      expect(Bundle.mas_installed?).to eql(true)
    end
  end
end
