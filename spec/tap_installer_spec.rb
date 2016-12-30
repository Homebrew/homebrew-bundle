require "spec_helper"

describe Bundle::TapInstaller do
  def do_install(clone_target = nil)
    Bundle::TapInstaller.install("phinze/cask", clone_target)
  end

  context ".installed_taps" do
    it "calls Homebrew" do
      Bundle::TapInstaller.installed_taps
    end
  end

  context "when tap is installed" do
    before do
      allow(Bundle::TapInstaller).to receive(:installed_taps).and_return(["phinze/cask"])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "skips" do
      expect(Bundle).not_to receive(:system)
      expect(do_install).to eql(:skipped)
    end
  end

  context "when tap is not installed" do
    before do
      allow(Bundle::TapInstaller).to receive(:installed_taps).and_return([])
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "taps" do
      expect(Bundle).to receive(:system).with("brew", "tap", "phinze/cask").and_return(true)
      expect(do_install).to eql(:success)
    end

    context "with clone target" do
      it "taps" do
        expect(Bundle).to receive(:system).with("brew", "tap", "phinze/cask", "clone_target_path").and_return(true)
        expect(do_install("clone_target_path")).to eql(:success)
      end
    end
  end
end
