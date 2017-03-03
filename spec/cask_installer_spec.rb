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
        expect(do_install).to eql(:skipped)
      end
    end

    context "when cask is not installed" do
      before do
        allow(Bundle::CaskInstaller).to receive(:installed_casks).and_return([])
      end

      it "installs cask" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "google-chrome").and_return(true)
        expect(do_install).to eql(:success)
      end

      it "installs cask with arguments" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "firefox", "--appdir=/Applications").and_return(true)
        expect(Bundle::CaskInstaller.install("firefox", args: { appdir: "/Applications" })).to eq(:success)
      end

      it "reports a failure" do
        expect(Bundle).to receive(:system).with("brew", "cask", "install", "google-chrome").and_return(false)
        expect(do_install).to eql(:failed)
      end

      context "with boolean arguments" do
        it "includes a flag if true" do
          expect(Bundle).to receive(:system).with("brew", "cask", "install", "iterm", "--force").and_return(true)
          expect(Bundle::CaskInstaller.install("iterm", args: { force: true })).to eq(:success)
        end

        it "does not include a flag if false" do
          expect(Bundle).to receive(:system).with("brew", "cask", "install", "iterm").and_return(true)
          expect(Bundle::CaskInstaller.install("iterm", args: { force: false })).to eq(:success)
        end
      end
    end
  end
end
