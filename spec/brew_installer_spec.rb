require "spec_helper"

describe Bundle::BrewInstaller do
  let(:formula) { "mysql" }
  let(:options) { { args: ["with-option"] } }
  let(:installer) { Bundle::BrewInstaller.new(formula, options) }

  def do_install
    installer.run
  end

  context "restart_service option is true" do
    context "formula is installed successfully" do
      before do
        allow(ARGV).to receive(:verbose?).and_return(false)
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:install_change_state!).and_return(:success)
      end

      it "restart service" do
        expect(Bundle::BrewServices).to receive(:restart).with(formula).and_return(true)
        Bundle::BrewInstaller.install(formula, restart_service: true)
      end
    end

    context "formula isn't installed" do
      before do
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:install_change_state!).and_return(:failed)
      end

      it "did not call restart service" do
        expect(Bundle::BrewServices).not_to receive(:restart)
        Bundle::BrewInstaller.install(formula, restart_service: true)
      end
    end
  end

  context "conflicts_with option is provided" do
    before do
      expect(Bundle::BrewDumper).to receive(:formula_info).and_return(
        name: "mysql",
        conflicts_with: ["mysql55"],
      )
      allow(Bundle::BrewInstaller).to receive(:formula_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewInstaller).to receive(:install).and_return(true)
      expect(Bundle).to receive(:system).with("brew", "unlink", "mysql55").and_return(true)
      expect(Bundle).to receive(:system).with("brew", "unlink", "mysql56").and_return(true)
      expect(Bundle::BrewServices).to receive(:stop).with("mysql55").and_return(true)
      expect(Bundle::BrewServices).to receive(:stop).with("mysql56").and_return(true)
      expect(Bundle::BrewServices).to receive(:restart).with(formula).and_return(true)
    end

    it "unlinks conflicts and stops their services" do
      allow(ARGV).to receive(:verbose?).and_return(false)
      Bundle::BrewInstaller.install(formula, restart_service: true, conflicts_with: ["mysql56"])
    end

    it "prints a message" do
      allow(ARGV).to receive(:verbose?).and_return(true)
      allow_any_instance_of(String).to receive(:undent).and_return("")
      allow_any_instance_of(Bundle::BrewInstaller).to receive(:puts)
      Bundle::BrewInstaller.install(formula, restart_service: true, conflicts_with: ["mysql56"])
    end
  end

  context ".outdated_formulae" do
    it "calls Homebrew" do
      Bundle::BrewInstaller.reset!
      expect(Bundle::BrewDumper).to receive(:formulae).and_return(
        [
          { name: "a", outdated?: true },
          { name: "b", outdated?: true },
          { name: "c", outdated?: false },
        ],
      )
      expect(Bundle::BrewInstaller.outdated_formulae).to eql(%w[a b])
    end
  end

  context ".pinned_formulae" do
    it "calls Homebrew" do
      Bundle::BrewInstaller.reset!
      expect(Bundle::BrewDumper).to receive(:formulae).and_return(
        [
          { name: "a", pinned?: true },
          { name: "b", pinned?: true },
          { name: "c", pinned?: false },
        ],
      )
      expect(Bundle::BrewInstaller.pinned_formulae).to eql(%w[a b])
    end
  end

  context ".formula_installed_and_up_to_date?" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewInstaller).to receive(:outdated_formulae).and_return(%w[bar])
      allow(Bundle::BrewDumper).to receive(:formulae).and_return [
        {
          name: "foo",
          full_name: "homebrew/tap/foo",
          aliases: ["foobar"],
          args: [],
          version: "1.0",
          dependencies: [],
          requirements: [],
        },
        {
          name: "bar",
          full_name: "bar",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          requirements: [],
        },
      ]
    end

    it "returns result" do
      expect(Bundle::BrewInstaller.formula_installed_and_up_to_date?("foo")).to eql(true)
      expect(Bundle::BrewInstaller.formula_installed_and_up_to_date?("foobar")).to eql(true)
      expect(Bundle::BrewInstaller.formula_installed_and_up_to_date?("bar")).to eql(false)
      expect(Bundle::BrewInstaller.formula_installed_and_up_to_date?("baz")).to eql(false)
    end
  end

  context "when brew is installed" do
    before do
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "when no formula is installed" do
      before do
        allow(Bundle::BrewInstaller).to receive(:installed_formulae).and_return([])
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:conflicts_with).and_return([])
      end

      it "install formula" do
        expect(Bundle).to receive(:system).with("brew", "install", formula, "--with-option").and_return(true)
        expect(do_install).to eql(:success)
      end

      it "reports a failure" do
        expect(Bundle).to receive(:system).with("brew", "install", formula, "--with-option").and_return(false)
        expect(do_install).to eql(:failed)
      end
    end

    context "when formula is installed" do
      before do
        allow(Bundle::BrewInstaller).to receive(:installed_formulae).and_return([formula])
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:conflicts_with).and_return([])
      end

      context "when formula upgradable" do
        before do
          allow(Bundle::BrewInstaller).to receive(:outdated_formulae).and_return([formula])
        end

        it "upgrade formula" do
          expect(Bundle).to receive(:system).with("brew", "upgrade", formula).and_return(true)
          expect(do_install).to eql(:success)
        end

        it "reports a failure" do
          expect(Bundle).to receive(:system).with("brew", "upgrade", formula).and_return(false)
          expect(do_install).to eql(:failed)
        end

        context "when formula pinned" do
          before do
            allow(Bundle::BrewInstaller).to receive(:pinned_formulae).and_return([formula])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system).with("brew", "upgrade", formula)
            expect(do_install).to eql(:skipped)
          end
        end

        context "when formula not upgraded" do
          before do
            allow(Bundle::BrewInstaller).to receive(:outdated_formulae).and_return([])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system)
            expect(do_install).to eql(:skipped)
          end
        end
      end
    end
  end

  context "#changed?" do
    it "should be false by default" do
      expect(Bundle::BrewInstaller.new(formula).changed?).to eql(false)
    end
  end

  context "#start_service?" do
    it "should be false by default" do
      expect(Bundle::BrewInstaller.new(formula).start_service?).to eql(false)
    end

    context "start_service option is true" do
      it "should be true" do
        expect(Bundle::BrewInstaller.new(formula, start_service: true).start_service?).to eql(true)
      end
    end
  end

  context "#restart_service?" do
    it "should be false by default" do
      expect(Bundle::BrewInstaller.new(formula).restart_service?).to eql(false)
    end

    context "restart_service option is true" do
      it "should be true" do
        expect(Bundle::BrewInstaller.new(formula, restart_service: true).restart_service?).to eql(true)
      end
    end

    context "restart_service option is changed" do
      it "should be true" do
        expect(Bundle::BrewInstaller.new(formula, restart_service: :changed).restart_service?).to eql(true)
      end
    end
  end

  context "#restart_service_needed?" do
    it "should be false by default" do
      expect(Bundle::BrewInstaller.new(formula).restart_service_needed?).to eql(false)
    end

    context "if a service is unchanged" do
      before do
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:changed?).and_return(false)
      end

      it "should be true with {restart_service: true}" do
        expect(Bundle::BrewInstaller.new(formula, restart_service: true).restart_service_needed?).to eql(true)
      end

      it "should be false if {restart_service: :changed}" do
        expect(Bundle::BrewInstaller.new(formula, restart_service: :changed).restart_service_needed?).to eql(false)
      end
    end

    context "if a service is changed" do
      before do
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:changed?).and_return(true)
      end

      it "should be true with {restart_service: true}" do
        expect(Bundle::BrewInstaller.new(formula, restart_service: true).restart_service_needed?).to eql(true)
      end

      it "should be true if {restart_service: :changed}" do
        expect(Bundle::BrewInstaller.new(formula, restart_service: :changed).restart_service_needed?).to eql(true)
      end
    end
  end
end
