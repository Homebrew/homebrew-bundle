require 'spec_helper'

describe Brewdler::Dsl do
  let(:dsl) { Brewdler::Dsl.new("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'\nbrew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']") }

  it "processes input" do
    dsl.should_receive(:tap).with('phinze/cask')
    dsl.should_receive(:brew).twice
    dsl.should_receive(:cask).with('google-chrome')
    dsl.process
  end
end
