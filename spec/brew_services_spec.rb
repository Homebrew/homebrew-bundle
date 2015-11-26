require "spec_helper"

describe Bundle::BrewServices do
  def restart_service
    Bundle::BrewServices.restart("nginx")
  end

  context "when brew-services is installed" do
    before do
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    it "restart the formula" do
      expect(Bundle).to receive(:system).with("brew", "services", "restart", "nginx").and_return(true)
      expect(restart_service).to eql(true)
    end
  end
end
