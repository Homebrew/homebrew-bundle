require "spec_helper"

describe Bundle::BrewInstaller do
  let(:formula) { "git" }
  let(:options) { { :args => ["with-option"] } }
  let(:installer) { Bundle::BrewInstaller.new(formula, options) }

  def do_install
    Bundler.with_clean_env { installer.install_or_upgrade }
  end

  context "restart_service option is true" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
    end

    context "formula is installed successfully" do
      before do
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:install_or_upgrade).and_return(true)
      end

      it "restart service" do
        expect(Bundle::BrewServices).to receive(:restart).with(formula).and_return(true)
        Bundle::BrewInstaller.install(formula, :restart_service => true)
      end
    end

    context "formula isn't installed" do
      before do
        allow_any_instance_of(Bundle::BrewInstaller).to receive(:install_or_upgrade).and_return(false)
      end

      it "did not call restart service" do
        expect(Bundle::BrewServices).not_to receive(:restart)
        Bundle::BrewInstaller.install(formula, :restart_service => true)
      end
    end
  end

  context ".outdated_formulae" do
    it "shells out" do
      Bundle::BrewInstaller.reset!
      expect(Bundle::BrewInstaller).to receive(:`).and_return("a\nhomebrew/tap/b")
      expect(Bundle::BrewInstaller.outdated_formulae).to eql(%w[a b])
    end
  end

  context ".pinned_formulae" do
    it "shells out" do
      Bundle::BrewInstaller.reset!
      expect(Bundle::BrewInstaller).to receive(:`).and_return("a\nb")
      expect(Bundle::BrewInstaller.pinned_formulae).to eql(%w[a b])
    end
  end

  context ".formula_installed_and_up_to_date?" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow(Bundle::BrewInstaller).to receive(:outdated_formulae).and_return(%w[bar])
      allow(Bundle::BrewDumper).to receive(:formulae).and_return [
        {
          :name => "foo",
          :full_name => "homebrew/tap/foo",
          :aliases => ["foobar"],
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [],
        },
        {
          :name => "bar",
          :full_name => "bar",
          :aliases => [],
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [],
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

  context "when brew is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(false)
      expect { do_install }.to raise_error(RuntimeError)
    end
  end

  context "when brew is installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow(ARGV).to receive(:verbose?).and_return(false)
    end

    context "when no formula is installed" do
      before do
        allow(Bundle::BrewInstaller).to receive(:installed_formulae).and_return([])
      end

      it "install formula" do
        expect(Bundle).to receive(:system).with("brew", "install", formula, "--with-option").and_return(true)
        expect(do_install).to eql(true)
      end
    end

    context "when formula is installed" do
      before do
        allow(Bundle::BrewInstaller).to receive(:installed_formulae).and_return([formula])
      end

      context "when formula upgradable" do
        before do
          allow(Bundle::BrewInstaller).to receive(:outdated_formulae).and_return([formula])
        end

        it "upgrade formula" do
          expect(Bundle).to receive(:system).with("brew", "upgrade", formula).and_return(true)
          expect(do_install).to eql(true)
        end

        context "when formula pinned" do
          before do
            allow(Bundle::BrewInstaller).to receive(:pinned_formulae).and_return([formula])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system).with("brew", "upgrade", formula)
            expect(do_install).to eql(true)
          end
        end

        context "when formula not upgrade" do
          before do
            allow(Bundle::BrewInstaller).to receive(:outdated_formulae).and_return([])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system)
            expect(do_install).to eql(true)
          end
        end
      end
    end
  end
end
