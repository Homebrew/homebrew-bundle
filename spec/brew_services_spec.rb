require "spec_helper"

describe Bundle::BrewServices do
  def restart_service
    Bundle::BrewServices.restart("nginx")
  end

  context "when brew-services is not installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
    end

    context "it tries to install brew-servies and successed" do
      it "works fine" do
        allow(Bundle).to receive(:services_installed?).and_return(false, true)
        expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/services").and_return(true)
        expect(Bundle).to receive(:system).with("brew", "services", "restart", "nginx").and_return(true)
        expect(restart_service).to eq(true)
      end
    end

    context "it tries to install brew-services and failed" do
      it "raises an error" do
        allow(Bundle).to receive(:services_installed?).and_return(false, false)
        expect(Bundle).to receive(:system).with("brew", "tap", "homebrew/services").and_return(true)
        expect { restart_service }.to raise_error
      end
    end
  end

  context "when brew-services is installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow(Bundle).to receive(:services_installed?).and_return(true)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "restart the formula" do
      expect(Bundle).to receive(:system).with("brew", "services", "restart", "nginx").and_return(true)
      expect(restart_service).to eql(true)
    end
  end
end
