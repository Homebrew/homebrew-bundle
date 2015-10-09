require "spec_helper"

describe Bundle::TapInstaller do
  def do_install(clone_target = nil)
    Bundle::TapInstaller.install("phinze/cask", clone_target)
  end

  context "when brew is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(false)
      expect { do_install }.to raise_error(RuntimeError)
    end
  end

  context '.installed_taps' do
    before do
      allow_any_instance_of(Bundle::TapInstaller).to receive(:`)
    end

    it 'shells out' do
      Bundler.with_clean_env { Bundle::TapInstaller.installed_taps }
    end
  end

  context "when tap is installed" do
    before do
       allow(Bundle::TapInstaller).to receive(:installed_taps).and_return(["phinze/cask"])
       allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "skips" do
      expect(Bundle).not_to receive(:system)
      expect(do_install).to eql(true)
    end
  end

  context "when tap is not installed" do
    before do
       allow(Bundle::TapInstaller).to receive(:installed_taps).and_return([])
       allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "taps" do
      expect(Bundle).to receive(:system).with("brew", "tap", "phinze/cask").and_return(true)
      expect(do_install).to eql(true)
    end

    context "with clone target" do
      it "taps" do
        expect(Bundle).to receive(:system).with("brew", "tap", "phinze/cask", "clone_target_path").and_return(true)
        expect(do_install("clone_target_path")).to eql(true)
      end
    end
  end
end
