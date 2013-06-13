require 'spec_helper'

describe Brewdler::Dsl do
  let(:dsl) { Brewdler::Dsl.new("brew 'git'\ncask 'google-chrome'") }

  it "processes input" do
    dsl.should_receive(:brew).with('git')
    dsl.should_receive(:cask).with('google-chrome')
    dsl.process
  end
end
