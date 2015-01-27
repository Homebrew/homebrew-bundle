require 'spec_helper'

describe Brewdler::Dsl do
  let(:dsl) { Brewdler::Dsl.new("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'\nbrew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']") }

  it "processes input" do
    expect(dsl).to receive(:tap).with('phinze/cask')
    expect(dsl).to receive(:brew).twice
    expect(dsl).to receive(:cask).with('google-chrome')
    dsl.process
  end
end
