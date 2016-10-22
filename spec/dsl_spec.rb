require "spec_helper"

describe Bundle::Dsl do
  it "processes input" do
    allow_any_instance_of(Bundle::Dsl).to receive(:system).with("/usr/libexec/java_home --failfast").and_return(false)
    allow(ARGV).to receive(:verbose?).and_return(true)
    # Keep in sync with the README
    dsl = Bundle::Dsl.new <<-EOS
      cask_args appdir: '/Applications'
      tap 'caskroom/cask'
      tap 'telemachus/brew', 'https://telemachus@bitbucket.org/telemachus/brew.git'
      brew 'imagemagick'
      brew 'mysql', restart_service: true, conflicts_with: ['homebrew/versions/mysql56']
      brew 'emacs', args: ['with-cocoa', 'with-gnutls']
      cask 'google-chrome'
      cask 'java' unless system '/usr/libexec/java_home --failfast'
      cask 'firefox', args: { appdir: '~/my-apps/Applications' }
      mas '1Password', id: 443987910
    EOS
    expect(dsl.cask_arguments).to eql(appdir: "/Applications")
    expect(dsl.entries[0].name).to eql("caskroom/cask")
    expect(dsl.entries[1].name).to eql("telemachus/brew")
    expect(dsl.entries[1].options).to eql(clone_target: "https://telemachus@bitbucket.org/telemachus/brew.git")
    expect(dsl.entries[2].name).to eql("imagemagick")
    expect(dsl.entries[3].name).to eql("mysql")
    expect(dsl.entries[3].options).to eql(restart_service: true, conflicts_with: ["homebrew/versions/mysql56"])
    expect(dsl.entries[4].name).to eql("emacs")
    expect(dsl.entries[4].options).to eql(args: ["with-cocoa", "with-gnutls"])
    expect(dsl.entries[5].name).to eql("google-chrome")
    expect(dsl.entries[6].name).to eql("java")
    expect(dsl.entries[7].name).to eql("firefox")
    expect(dsl.entries[7].options).to eql(args: { appdir: "~/my-apps/Applications" })
    expect(dsl.entries[8].name).to eql("1Password")
    expect(dsl.entries[8].options).to eql(id: 443_987_910)
  end

  it "handles invalid input" do
    allow(ARGV).to receive(:verbose?).and_return(true)
    expect { Bundle::Dsl.new "abcdef" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "cask_args ''" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "brew 1" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "brew 'foo', ['bad_option']" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "cask 1" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "cask 'foo', ['bad_option']" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "tap 1" }.to raise_error(RuntimeError)
    expect { Bundle::Dsl.new "tap 'foo', ['bad_clone_target']" }.to raise_error(RuntimeError)
  end

  it ".sanitize_brew_name" do
    expect(Bundle::Dsl.send(:sanitize_brew_name, "homebrew/homebrew/foo")).to eql("foo")
    expect(Bundle::Dsl.send(:sanitize_brew_name, "homebrew/homebrew-bar/foo")).to eql("homebrew/bar/foo")
    expect(Bundle::Dsl.send(:sanitize_brew_name, "homebrew/bar/foo")).to eql("homebrew/bar/foo")
    expect(Bundle::Dsl.send(:sanitize_brew_name, "foo")).to eql("foo")
  end

  it ".sanitize_tap_name" do
    expect(Bundle::Dsl.send(:sanitize_tap_name, "homebrew/homebrew-foo")).to eql("homebrew/foo")
    expect(Bundle::Dsl.send(:sanitize_tap_name, "homebrew/foo")).to eql("homebrew/foo")
  end
end
