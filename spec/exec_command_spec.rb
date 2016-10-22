require "spec_helper"

describe Bundle::Commands::Exec do
  context "when a Brewfile is not found" do
    it "raises an error" do
      allow(ARGV).to receive(:value).and_return(nil)
      expect { Bundle::Commands::Exec.run }.to raise_error(RuntimeError)
    end
  end

  context "when a Brewfile is found" do
    it "does not raise an error" do
      stub_const("ARGV", ["bundle", "install"])
      allow(Bundle::Commands::Exec).to receive(:exec).and_return(nil)
      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { Bundle::Commands::Exec.run }.to_not raise_error
    end

    it "should be able to run without bundle arguments" do
      stub_const("ARGV", ["bundle", "install"])
      allow(Bundle::Commands::Exec).to receive(:exec).with("bundle", "install").and_return(nil)
      allow(ARGV).to receive(:value).and_return(nil)
      allow(ARGV).to receive(:verbose?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { Bundle::Commands::Exec.run }.to_not raise_error
    end

    it "should be able to accept arguments passed prior to the command" do
      stub_const("ARGV", ["--verbose", "--", "bundle", "install"])
      allow(Bundle::Commands::Exec).to receive(:exec).with("bundle", "install").and_return(nil)
      allow(ARGV).to receive(:value).and_return(nil)
      allow(ARGV).to receive(:verbose?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { Bundle::Commands::Exec.run }.to_not raise_error
    end

    it "should raise an exception if called without a command" do
      stub_const("ARGV", [])
      allow(Bundle::Commands::Exec).to receive(:exec).and_return(nil)
      allow(ARGV).to receive(:value).and_return(nil)
      allow(ARGV).to receive(:verbose?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { Bundle::Commands::Exec.run }.to raise_error(RuntimeError)
    end

    it "should raise if called with a command that's not on the PATH" do
      stub_const("ARGV", ["bundle", "install"])
      allow(Bundle::Commands::Exec).to receive(:exec).and_return(nil)
      allow(Bundle::Commands::Exec).to receive(:which).and_return(nil)
      allow(ARGV).to receive(:value).and_return(nil)
      allow(ARGV).to receive(:verbose?).and_return(true)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")

      expect { Bundle::Commands::Exec.run }.to raise_error(RuntimeError)
    end

    it "should prepend the path of the requested command to PATH before running" do
      stub_const("ARGV", ["bundle", "install"])
      allow(Bundle::Commands::Exec).to receive(:exec).with("bundle", "install").and_return(nil)
      allow(Bundle::Commands::Exec).to receive(:which).and_return(Pathname("/usr/local/bin/bundle"))
      allow(ARGV).to receive(:value).and_return(nil)
      allow(ARGV).to receive(:verbose?).and_return(true)
      allow(ENV).to receive(:prepend_path).with("/usr/local/bin").and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read)
        .and_return("brew 'openssl'")
    end
  end
end
