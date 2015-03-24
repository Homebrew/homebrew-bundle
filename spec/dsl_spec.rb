require 'spec_helper'

describe Brewdler::Dsl do
  it "processes input" do
    expect_any_instance_of(Brewdler::Dsl).to receive(:tap).with('phinze/cask')
    expect_any_instance_of(Brewdler::Dsl).to receive(:brew).twice
    expect_any_instance_of(Brewdler::Dsl).to receive(:cask).with('google-chrome')
    Brewdler::Dsl.new("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'\nbrew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']")
  end
end
