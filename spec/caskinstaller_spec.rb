require "spec_helper"

describe Bundle::CaskInstaller do
  def do_install
    Bundle::CaskInstaller.install("google-chrome")
  end

  context "when brew-cask is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:cask_installed?).and_return(false)
      expect { do_install }.to raise_error
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
    end
  end
end
