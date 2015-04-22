require 'spec_helper'

describe Bundle::Dsl do
  it "processes input" do
    expect_any_instance_of(Bundle::Dsl).to receive(:tap).with('phinze/cask')
    expect_any_instance_of(Bundle::Dsl).to receive(:brew).twice
    expect_any_instance_of(Bundle::Dsl).to receive(:cask).with('google-chrome')
    Bundle::Dsl.new("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'\nbrew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']")
  end

  describe '#brew' do
    context 'when one formula is passed' do
      it 'adds entry for that formula' do
        expect(Bundle::Dsl::Entry).to receive(:new).with(:brew, 'git', {})
        Bundle::Dsl.new("brew 'git'")
      end

      context 'and options hash is passed' do
        it 'passes the options hash to the entry' do
          expect(Bundle::Dsl::Entry).to receive(:new).with(:brew, 'emacs', args: %w(cocoa srgb with-gnutls))
          Bundle::Dsl.new("brew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']")
        end
      end
    end

    context 'when multiple formulae are passed' do
      it 'adds entries for each formula' do
        expect(Bundle::Dsl::Entry).to receive(:new).with(:brew, 'git', {})
        expect(Bundle::Dsl::Entry).to receive(:new).with(:brew, 'emacs', {})
        Bundle::Dsl.new("brew 'git'\nbrew 'emacs'")
      end

      context 'and an options hash is also passed' do
        it 'passes the options to the entries for every formula' do
          expect(Bundle::Dsl::Entry).to receive(:new).with(:brew, 'git', { args: ['cocoa', 'srgb', 'with-gnutls'] })
          expect(Bundle::Dsl::Entry).to receive(:new).with(:brew, 'emacs', { args: ['cocoa', 'srgb', 'with-gnutls'] })
          Bundle::Dsl.new("brew 'git', 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']")
        end
      end
    end
  end

  describe '#cask' do
    context 'when multiple casks are passed' do
      it 'adds entries for each cask' do
        expect(Bundle::Dsl::Entry).to receive(:new).with(:cask, 'google-chrome')
        expect(Bundle::Dsl::Entry).to receive(:new).with(:cask, 'firefox')
        Bundle::Dsl.new("cask 'google-chrome', 'firefox'")
      end
    end
  end

  describe '#tap' do
    context 'when multiple taps are passed' do
      it 'adds entries for each tap' do
        expect(Bundle::Dsl::Entry).to receive(:new).with(:repo, 'phinze/cask')
        expect(Bundle::Dsl::Entry).to receive(:new).with(:repo, 'homebrew/versions')
        Bundle::Dsl.new("tap 'phinze/cask', 'homebrew/versions'")
      end
    end
  end
end
