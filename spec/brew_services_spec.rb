require "spec_helper"

describe Bundle::BrewServices do
  context ".started_services" do
    before do
      Bundle::BrewServices.reset!
    end

    it "is empty when brew servies not installed" do
      allow(Bundle).to receive(:services_installed?).and_return(false)
      expect(Bundle::BrewServices.started_services).to be_empty
    end

    it "returns started services" do
      allow(Bundle).to receive(:services_installed?).and_return(true)
      allow(Bundle::BrewServices).to receive(:`).and_return <<-EOS.unindent
        nginx  started  homebrew.mxcl.nginx.plist
        apache stopped  homebrew.mxcl.apache.plist
        mysql  started  homebrew.mxcl.mysql.plist
      EOS
      expect(Bundle::BrewServices.started_services).to contain_exactly("nginx", "mysql")
    end
  end

  context "when brew-services is installed" do
    before do
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "stops the service" do
      it "when the service is started" do
        allow(Bundle::BrewServices).to receive(:started_services).and_return(%w[nginx])
        expect(Bundle).to receive(:system).with("brew", "services", "stop", "nginx").and_return(true)
        expect(Bundle::BrewServices.stop("nginx")).to eql(true)
        expect(Bundle::BrewServices.started_services).not_to include("nginx")
      end

      it "when the service is already stopped" do
        allow(Bundle::BrewServices).to receive(:started_services).and_return(%w[])
        expect(Bundle).to_not receive(:system).with("brew", "services", "stop", "nginx")
        expect(Bundle::BrewServices.stop("nginx")).to eql(true)
        expect(Bundle::BrewServices.started_services).not_to include("nginx")
      end
    end

    it "restarts the service" do
      allow(Bundle::BrewServices).to receive(:started_services).and_return([])
      expect(Bundle).to receive(:system).with("brew", "services", "restart", "nginx").and_return(true)
      expect(Bundle::BrewServices.restart("nginx")).to eql(true)
      expect(Bundle::BrewServices.started_services).to include("nginx")
    end
  end
end
