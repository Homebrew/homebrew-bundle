require "spec_helper"

describe Bundle::BrewInstaller do
  let(:formula) { "git" }
  let(:options) { { args: ["with-option"] } }
  let(:installer) { Bundle::BrewInstaller.new(formula, options) }

  def do_install
    installer.install_or_upgrade
  end

  context "when brew is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(false)
      expect { do_install }.to raise_error
    end
  end

  context "when brew is installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
    end

    context "when no formula is installed" do
      before do
        allow(installer).to receive(:installed_formulae).and_return([])
      end

      it "install formula" do
        expect(Bundle).to receive(:system).with("brew", "install", formula, "--with-option").and_return(true)
        expect(do_install).to eql(true)
      end
    end

    context "when formula is installed" do
      before do
        allow(installer).to receive(:installed_formulae).and_return([formula])
      end

      context "when formula upgradable" do
        before do
          allow(installer).to receive(:outdated_formulae).and_return([formula])
        end

        it "upgrade formula" do
          expect(Bundle).to receive(:system).with("brew", "upgrade", formula).and_return(true)
          expect(do_install).to eql(true)
        end

        context "when formula pinned" do
          before do
            allow(installer).to receive(:pinned_formulae).and_return([formula])
          end

          it "does not upgrade formula" do
            expect(Bundle).not_to receive(:system).with("brew", "upgrade", formula)
            expect(do_install).to eql(true)
          end
        end

        context "when formula not upgrade" do
          before do
            allow(installer).to receive(:outdated_formulae).and_return([])
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
