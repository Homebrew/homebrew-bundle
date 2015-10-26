require "spec_helper"

describe Bundle::Dsl do
  it "processes input" do
    expect_any_instance_of(Bundle::Dsl).to receive(:tap).with("caskroom/cask")
    expect_any_instance_of(Bundle::Dsl).to receive(:tap).with(
      "telemachus/brew",
      "https://telemachus@bitbucket.org/telemachus/brew.git",
    )
    expect_any_instance_of(Bundle::Dsl).to receive(:brew).twice
    expect_any_instance_of(Bundle::Dsl).to receive(:cask).with("google-chrome")
    expect_any_instance_of(Bundle::Dsl).to receive(:cask_args).with(:appdir => "/Applications")
    expect_any_instance_of(Bundle::Dsl).to receive(:cask).with("firefox", :args => {:appdir => "~/my-apps/Applications"})
    Bundle::Dsl.new <<-EOS
      cask_args :appdir => "/Applications"
      tap 'caskroom/cask'
      tap 'telemachus/brew', 'https://telemachus@bitbucket.org/telemachus/brew.git'
      brew 'git'
      brew 'emacs', args: ['with-cocoa', 'with-gnutls']
      cask 'google-chrome'
      cask 'firefox', args: { appdir: '~/my-apps/Applications' }
    EOS
  end

  it "handles invalid input" do
    allow(ARGV).to receive(:verbose?).and_return(true)
    expect { Bundle::Dsl.new "abcdef" }.to raise_error(RuntimeError)
  end
end
