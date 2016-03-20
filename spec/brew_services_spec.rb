require "spec_helper"

describe Bundle::BrewServices do
  context "when brew-services is installed" do
    before do
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "stops the service" do
      it "when the service is started" do
        allow(Bundle::BrewServices).to receive(:`).and_return <<-EOS
nginx  started  homebrew.mxcl.nginx.plist
apache stopped  homebrew.mxcl.apache.plist
mysql  started  homebrew.mxcl.mysql.plist
EOS
        expect(Bundle).to receive(:system).with("brew", "services", "stop", "nginx").and_return(true)
        expect(Bundle::BrewServices.stop("nginx")).to eql(true)
      end

      it "when the service is already stopped" do
        allow(Bundle::BrewServices).to receive(:`).and_return("")
        expect(Bundle).to_not receive(:system).with("brew", "services", "stop", "nginx")
        expect(Bundle::BrewServices.stop("nginx")).to eql(true)
      end
    end

    it "restarts the service" do
      expect(Bundle).to receive(:system).with("brew", "services", "restart", "nginx").and_return(true)
      expect(Bundle::BrewServices.restart("nginx")).to eql(true)
    end
  end
end
