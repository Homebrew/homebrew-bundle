# frozen_string_literal: true

require "spec_helper"

describe Bundle::BrewInstaller do
  let(:formula) { "mysql" }
  let(:options) { { args: ["with-option"] } }
  let(:installer) { described_class.new(formula, options) }

  def do_install
    installer.run
  end

  context "restart_service option is true" do
    context "formula is installed successfully" do
      before do
        allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(:success)
      end

      it "restart service" do
        expect(Bundle::BrewServices).to receive(:restart).with(formula, verbose: false).and_return(true)
        described_class.install(formula, restart_service: true)
      end
    end

    context "formula isn't installed" do
      before do
        allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(:failed)
      end

      it "did not call restart service" do
        expect(Bundle::BrewServices).not_to receive(:restart)
        described_class.install(formula, restart_service: true)
      end
    end
  end

  context "link option is true" do
    before do
      allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(:success)
    end

    it "links formula" do
      expect(Bundle).to receive(:system).with("brew", "link", "--force", "mysql", verbose: false).and_return(true)
      described_class.install(formula, link: true)
    end
  end

  context "link option is false" do
    before do
      allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(:success)
    end

    it "unlinks formula" do
      expect(Bundle).to receive(:system).with("brew", "unlink", "mysql", verbose: false).and_return(true)
      described_class.install(formula, link: false)
    end
  end

  context "link option is nil and formula is unlinked and not keg-only" do
    before do
      allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(:success)
    end

    it "links formula" do
      allow_any_instance_of(described_class).to receive(:unlinked_and_not_keg_only?).and_return(true)
      expect(Bundle).to receive(:system).with("brew", "link", "mysql", verbose: false).and_return(true)
      described_class.install(formula, link: nil)
    end
  end

  context "link option is nil and formula is linked and keg-only" do
    before do
      allow_any_instance_of(described_class).to receive(:install_change_state!).and_return(:success)
    end

    it "unlinks formula" do
      allow_any_instance_of(described_class).to receive(:linked_and_keg_only?).and_return(true)
      expect(Bundle).to receive(:system).with("brew", "unlink", "mysql", verbose: false).and_return(true)
      described_class.install(formula, link: nil)
    end
  end

  context "conflicts_with option is provided" do
    before do
      allow(Bundle::BrewDumper).to receive(:formula_info).and_return(
        name:           "mysql",
        conflicts_with: ["mysql55"],
      )
      allow(described_class).to receive(:formula_installed?).and_return(true)
      allow_any_instance_of(described_class).to receive(:install).and_return(true)
    end

    def sane?(verbose:)
      expect(Bundle).to receive(:system).with("brew", "unlink", "mysql55", verbose: verbose).and_return(true)
      expect(Bundle).to receive(:system).with("brew", "unlink", "mysql56", verbose: verbose).and_return(true)
      expect(Bundle::BrewServices).to receive(:stop).with("mysql55", verbose: verbose).and_return(true)
      expect(Bundle::BrewServices).to receive(:stop).with("mysql56", verbose: verbose).and_return(true)
      expect(Bundle::BrewServices).to receive(:restart).with(formula, verbose: verbose).and_return(true)
    end

    it "unlinks conflicts and stops their services" do
      sane?(verbose: false)
      described_class.install(formula, restart_service: true, conflicts_with: ["mysql56"])
    end

    it "prints a message" do
      allow_any_instance_of(described_class).to receive(:puts)
      sane?(verbose: true)
      described_class.install(formula, restart_service: true, conflicts_with: ["mysql56"], verbose: true)
    end
  end

  describe ".outdated_formulae" do
    it "calls Homebrew" do
      described_class.reset!
      expect(Bundle::BrewDumper).to receive(:formulae).and_return(
        [
          { name: "a", outdated?: true },
          { name: "b", outdated?: true },
          { name: "c", outdated?: false },
        ],
      )
      expect(described_class.outdated_formulae).to eql(%w[a b])
    end
  end

  describe ".pinned_formulae" do
    it "calls Homebrew" do
      described_class.reset!
      expect(Bundle::BrewDumper).to receive(:formulae).and_return(
        [
          { name: "a", pinned?: true },
          { name: "b", pinned?: true },
          { name: "c", pinned?: false },
        ],
      )
      expect(described_class.pinned_formulae).to eql(%w[a b])
    end
  end

  describe ".formula_installed_and_up_to_date?" do
    before do
      Bundle::BrewDumper.reset!
      described_class.reset!
      allow(described_class).to receive(:outdated_formulae).and_return(%w[bar])
      allow_any_instance_of(Formula).to receive(:outdated?).and_return(true)
      allow(Bundle::BrewDumper).to receive(:formulae).and_return [
        {
          name:         "foo",
          full_name:    "homebrew/tap/foo",
          aliases:      ["foobar"],
          args:         [],
          version:      "1.0",
          dependencies: [],
          requirements: [],
        },
        {
          name:         "bar",
          full_name:    "bar",
          aliases:      [],
          args:         [],
          version:      "1.0",
          dependencies: [],
          requirements: [],
        },
      ]
    end

    it "returns result" do
      expect(described_class.formula_installed_and_up_to_date?("foo")).to be(true)
      expect(described_class.formula_installed_and_up_to_date?("foobar")).to be(true)
      expect(described_class.formula_installed_and_up_to_date?("bar")).to be(false)
      expect(described_class.formula_installed_and_up_to_date?("baz")).to be(false)
    end
  end

  context "when brew is installed" do
    context "when no formula is installed" do
      before do
        allow(described_class).to receive(:installed_formulae).and_return([])
        allow_any_instance_of(described_class).to receive(:conflicts_with).and_return([])
      end

      it "install formula" do
        expect(Bundle).to receive(:system).with("brew", "install", formula, "--with-option", verbose: false)
                                          .and_return(true)
        expect(do_install).to be(:success)
      end

      it "reports a failure" do
        expect(Bundle).to receive(:system).with("brew", "install", formula, "--with-option", verbose: false)
                                          .and_return(false)
        expect(do_install).to be(:failed)
      end
    end

    context "when formula is installed" do
      before do
        allow(described_class).to receive(:installed_formulae).and_return([formula])
        allow_any_instance_of(described_class).to receive(:conflicts_with).and_return([])
        allow_any_instance_of(Formula).to receive(:outdated?).and_return(true)
      end

      context "when formula upgradable" do
        before do
          allow(described_class).to receive(:outdated_formulae).and_return([formula])
        end

        it "upgrade formula" do
          expect(Bundle).to receive(:system).with("brew", "upgrade", formula, verbose: false).and_return(true)
          expect(do_install).to be(:success)
        end

        it "reports a failure" do
          expect(Bundle).to receive(:system).with("brew", "upgrade", formula, verbose: false).and_return(false)
          expect(do_install).to be(:failed)
        end

        context "when formula pinned" do
          before do
            allow(described_class).to receive(:pinned_formulae).and_return([formula])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system).with("brew", "upgrade", formula, verbose: false)
            expect(do_install).to be(:skipped)
          end
        end

        context "when formula not upgraded" do
          before do
            allow(described_class).to receive(:outdated_formulae).and_return([])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system)
            expect(do_install).to be(:skipped)
          end
        end
      end
    end
  end

  describe "#changed?" do
    it "is false by default" do
      expect(described_class.new(formula).changed?).to be(false)
    end
  end

  describe "#start_service?" do
    it "is false by default" do
      expect(described_class.new(formula).start_service?).to be(false)
    end

    context "start_service option is true" do
      it "is true" do
        expect(described_class.new(formula, start_service: true).start_service?).to be(true)
      end
    end
  end

  describe "#restart_service?" do
    it "is false by default" do
      expect(described_class.new(formula).restart_service?).to be(false)
    end

    context "restart_service option is true" do
      it "is true" do
        expect(described_class.new(formula, restart_service: true).restart_service?).to be(true)
      end
    end

    context "restart_service option is changed" do
      it "is true" do
        expect(described_class.new(formula, restart_service: :changed).restart_service?).to be(true)
      end
    end
  end

  describe "#restart_service_needed?" do
    it "is false by default" do
      expect(described_class.new(formula).restart_service_needed?).to be(false)
    end

    context "if a service is unchanged" do
      before do
        allow_any_instance_of(described_class).to receive(:changed?).and_return(false)
      end

      it "is true with {restart_service: true}" do
        expect(described_class.new(formula, restart_service: true).restart_service_needed?).to be(true)
      end

      it "is false if {restart_service: :changed}" do
        expect(described_class.new(formula, restart_service: :changed).restart_service_needed?).to be(false)
      end
    end

    context "if a service is changed" do
      before do
        allow_any_instance_of(described_class).to receive(:changed?).and_return(true)
      end

      it "is true with {restart_service: true}" do
        expect(described_class.new(formula, restart_service: true).restart_service_needed?).to be(true)
      end

      it "is true if {restart_service: :changed}" do
        expect(described_class.new(formula, restart_service: :changed).restart_service_needed?).to be(true)
      end
    end
  end
end
