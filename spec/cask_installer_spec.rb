require "spec_helper"

describe Bundle::CaskInstaller do
  def do_install
    Bundle::CaskInstaller.install("google-chrome")
  end

  context ".installed_casks" do
    it "shells out" do
      Bundle::CaskInstaller.installed_casks
    end
  end

  context "when brew-cask is installed" do
    before do
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "when cask is installed" do
      before do
        allow(Bundle::CaskInstaller).to receive(:installed_casks).and_return(["google-chrome"])
      end

      it "skips" do
        expect(Bundle).not_to receive(:system)
        expect(do_install).to eql(true)
      end
    end

    context "when cask is not installed" do
      before do
        allow(Bundle::CaskInstaller).to receive(:installed_casks).and_return([])
      end

      it "installs cask" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "google-chrome").and_return(true)
        expect(do_install).to eql(true)
      end

      it "installs cask with arguments" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "firefox", "--appdir=/Applications").and_return(true)
        expect(Bundle::CaskInstaller.install("firefox", :args => { :appdir => "/Applications" })).to eq(true)
      end
    end
  end
end
