require 'spec_helper'

describe Bundle::Dsl do
  it "processes input" do
    expect_any_instance_of(Bundle::Dsl).to receive(:tap).with('phinze/cask')
    expect_any_instance_of(Bundle::Dsl).to receive(:brew).twice
    expect_any_instance_of(Bundle::Dsl).to receive(:cask).with('google-chrome')
    Bundle::Dsl.new("tap 'phinze/cask'\nbrew 'git'\ncask 'google-chrome'\nbrew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']")
  end
end
