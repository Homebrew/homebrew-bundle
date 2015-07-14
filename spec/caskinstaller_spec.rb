require "spec_helper"

describe Bundle::CaskInstaller do
  def do_install
    Bundle::CaskInstaller.install("google-chrome")
  end

  context "when brew is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(false)
      expect { do_install }.to raise_error
    end
  end

  context "when brew-cask is not installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
    end

    context "it tries to install brew-cask and successed" do
      it "works fine" do
        allow(Bundle).to receive(:cask_installed?).and_return(false, true)
        allow(Bundle::CaskInstaller).to receive(:installed_casks).and_return([])
        expect(Bundle).to receive(:system).with("brew", "install", "caskroom/cask/brew-cask").and_return(true)
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "google-chrome").and_return(true)
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "firefox", "--appdir=/Applications").and_return(true)
        expect(do_install).to eq(true)
      end
    end

    context "it tries to install brew-cask and failed" do
      it "raises an error" do
        allow(Bundle).to receive(:cask_installed?).and_return(false, false)
        expect(Bundle).to receive(:system).with("brew", "install", "caskroom/cask/brew-cask")
        expect { do_install }.to raise_error
      end
    end
  end

  context "when brew-cask is installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow(Bundle).to receive(:cask_installed?).and_return(true)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "when cask is installed" do
      before do
         allow(Bundle::CaskInstaller).to receive(:installed_casks).and_return(["google-chrome","firefox"])
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
    end
  end
end
