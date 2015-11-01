require "spec_helper"

describe Bundle::Dsl do
  it "processes input" do
    allow(ARGV).to receive(:verbose?).and_return(true)
    dsl = Bundle::Dsl.new <<-EOS
      cask_args :appdir => "/Applications"
      tap 'caskroom/cask'
      tap 'telemachus/brew', 'https://telemachus@bitbucket.org/telemachus/brew.git'
      brew 'git'
      brew 'emacs', args: ['with-cocoa', 'with-gnutls']
      cask 'google-chrome'
      cask 'firefox', args: { appdir: '~/my-apps/Applications' }
    EOS
    expect(dsl.entries[0].name).to eql("caskroom/cask")
    expect(dsl.entries[1].name).to eql("telemachus/brew")
    expect(dsl.entries[1].options).to eql(:clone_target => "https://telemachus@bitbucket.org/telemachus/brew.git")
    expect(dsl.entries[2].name).to eql("git")
    expect(dsl.entries[3].name).to eql("emacs")
    expect(dsl.entries[3].options).to eql(:args => ["with-cocoa", "with-gnutls"])
    expect(dsl.entries[4].name).to eql("google-chrome")
    expect(dsl.entries[4].options).to eql(:args => {:appdir=>"/Applications"})
    expect(dsl.entries[5].name).to eql("firefox")
    expect(dsl.entries[5].options).to eql(:args => {:appdir=>"~/my-apps/Applications"})
  end

  it "handles invalid input" do
    allow(ARGV).to receive(:verbose?).and_return(true)
    expect { Bundle::Dsl.new "abcdef" }.to raise_error(RuntimeError)
  end
end
