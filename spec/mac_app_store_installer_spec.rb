require "spec_helper"

describe Bundle::MacAppStoreInstaller do
  def do_install
    Bundle::MacAppStoreInstaller.install("foo", 123)
  end

  context ".installed_app_ids" do
    it "shells out" do
      Bundle::MacAppStoreInstaller.installed_app_ids
    end
  end

  context "when mas is not installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(false)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "tries to install mas" do
      expect(Bundle).to receive(:system).with("brew", "install", "mas").and_return(true)
      expect { do_install }.to raise_error(RuntimeError)
    end
  end

  context "when mas is installed" do
    before do
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "when mas is not signed in" do
      before do
        allow(ARGV).to receive(:verbose?).and_return(false)
      end

      it "tries to sign in with mas" do
        expect(Bundle).to receive(:system).with("mas", "account").and_return(false).twice
        expect(Bundle).to receive(:system).with("mas", "signin", "--dialog", "").and_return(true)
        expect { do_install }.to raise_error(RuntimeError)
      end
    end

    context "when mas is signed in" do
      before do
        allow(Bundle).to receive(:mas_signedin?).and_return(true)
        allow(ARGV).to receive(:verbose?).and_return(false)
      end

      context "when app is installed" do
        before do
          allow(Bundle::MacAppStoreInstaller).to receive(:installed_app_ids).and_return([123])
        end

        it "skips" do
          expect(Bundle).not_to receive(:system)
          expect(do_install).to eql(:skipped)
        end
      end

      context "when app is not installed" do
        before do
          allow(Bundle::MacAppStoreInstaller).to receive(:installed_app_ids).and_return([])
        end

        it "installs app" do
          expect(Bundle).to receive(:system).with("mas", "install", "123").and_return(true)
          expect(do_install).to eql(:success)
        end
      end
    end
  end
end
