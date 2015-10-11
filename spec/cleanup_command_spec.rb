require "spec_helper"

describe Bundle::Commands::Cleanup do
  context "read Brewfile and currently installation" do
    before do
      allow(ARGV).to receive(:value).and_return(nil)
      allow_any_instance_of(Pathname).to receive(:read).and_return <<-EOS
        tap 'x'
        tap 'y'
        cask '123'
        brew 'a'
        brew 'b'
        brew 'd'
        brew 'homebrew/tap/f'
        brew 'homebrew/tap/g'
        brew 'homebrew/tap/h'
      EOS
    end

    it "computes which casks to uninstall" do
      allow_any_instance_of(Bundle::CaskDumper).to receive(:casks).and_return(%w[123 456])
      expect(Bundle::Commands::Cleanup.casks_to_uninstall).to eql(%w[456])
    end

    it "computes which formulae to uninstall" do
      allow(Bundle::BrewDumper).to receive_message_chain(:new, :formulae).and_return [
        { :name => "a", :full_name => "a" },
        { :name => "c", :full_name => "c" },
        { :name => "d", :full_name => "homebrew/tap/d" },
        { :name => "e", :full_name => "homebrew/tap/e" },
        { :name => "f", :full_name => "homebrew/tap/f" },
        { :name => "h", :full_name => "other/tap/h" },
      ]
      expect(Bundle::Commands::Cleanup.formulae_to_uninstall).to eql %w[
        c
        homebrew/tap/e
        other/tap/h
      ]
    end

    it "computes which tap to untap" do
      allow(Bundle::Commands::Cleanup).to receive(:`).and_return("x\nz")
      expect(Bundle::Commands::Cleanup.taps_to_untap).to eql(%w[z])
    end
  end

  context "no formulae to uninstall and no taps to untap" do
    before do
      allow(Bundle::Commands::Cleanup).to receive(:casks_to_uninstall).and_return([])
      allow(Bundle::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return([])
      allow(Bundle::Commands::Cleanup).to receive(:taps_to_untap).and_return([])
      allow(ARGV).to receive(:force?).and_return(true)
    end

    it "does nothing" do
      expect(Kernel).not_to receive(:system)
      Bundle::Commands::Cleanup.run
    end
  end

  context "there are casks to uninstall" do
    before do
      allow(Bundle::Commands::Cleanup).to receive(:casks_to_uninstall).and_return(%w[a b])
      allow(Bundle::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return([])
      allow(Bundle::Commands::Cleanup).to receive(:taps_to_untap).and_return([])
      allow(ARGV).to receive(:force?).and_return(true)
    end

    it "uninstalls casks" do
      expect(Kernel).to receive(:system).with(*%w[brew cask uninstall --force a b])
      expect { Bundle::Commands::Cleanup.run }.to output(/Uninstalled 2 casks/).to_stdout
    end
  end

  context "there are formulae to uninstall" do
    before do
      allow(Bundle::Commands::Cleanup).to receive(:casks_to_uninstall).and_return([])
      allow(Bundle::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return(%w[a b])
      allow(Bundle::Commands::Cleanup).to receive(:taps_to_untap).and_return([])
      allow(ARGV).to receive(:force?).and_return(true)
    end

    it "uninstalls formulae" do
      expect(Kernel).to receive(:system).with(*%w[brew uninstall --force a b])
      expect { Bundle::Commands::Cleanup.run }.to output(/Uninstalled 2 formulae/).to_stdout
    end
  end

  context "there are taps to untap" do
    before do
      allow(Bundle::Commands::Cleanup).to receive(:casks_to_uninstall).and_return([])
      allow(Bundle::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return([])
      allow(Bundle::Commands::Cleanup).to receive(:taps_to_untap).and_return(%w[a b])
      allow(ARGV).to receive(:force?).and_return(true)
    end

    it "untaps taps" do
      expect(Kernel).to receive(:system).with(*%w[brew untap a b])
      Bundle::Commands::Cleanup.run
    end
  end

  context "there are casks and formulae to uninstall and taps to untap but without passing `--force`" do
    before do
      allow(Bundle::Commands::Cleanup).to receive(:casks_to_uninstall).and_return(%w[a b])
      allow(Bundle::Commands::Cleanup).to receive(:formulae_to_uninstall).and_return(%w[a b])
      allow(Bundle::Commands::Cleanup).to receive(:taps_to_untap).and_return(%w[a b])
      allow(ARGV).to receive(:force?).and_return(false)
    end

    it "lists casks, formulae and taps" do
      expect(Bundle::Commands::Cleanup).to receive(:puts_columns).with(%w[a b]).exactly(3).times
      expect(Kernel).not_to receive(:system)
      expect { Bundle::Commands::Cleanup.run }.to output(/Would uninstall formulae:.*Would untap:/m).to_stdout
    end
  end
end
