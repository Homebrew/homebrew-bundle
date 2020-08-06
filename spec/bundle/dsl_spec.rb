# frozen_string_literal: true

require "spec_helper"

describe Bundle::Dsl do
  context "with a DSL example" do
    subject(:dsl) do
      described_class.new <<~EOS
        # frozen_string_literal: true
        cask_args appdir: '/Applications'
        tap 'homebrew/cask'
        tap 'telemachus/brew', 'https://telemachus@bitbucket.org/telemachus/brew.git', pin: true
        brew 'imagemagick'
        brew 'mysql@5.6', restart_service: true, link: true, conflicts_with: ['mysql']
        brew 'emacs', args: ['with-cocoa', 'with-gnutls']
        cask 'google-chrome'
        cask 'java' unless system '/usr/libexec/java_home --failfast'
        cask 'firefox', args: { appdir: '~/my-apps/Applications' }
        mas '1Password', id: 443987910
        whalebrew 'whalebrew/wget'
      EOS
    end

    before do
      allow_any_instance_of(described_class).to receive(:system)
        .with("/usr/libexec/java_home --failfast")
        .and_return(false)
    end

    it "processes input" do
      # Keep in sync with the README
      expect(dsl.cask_arguments).to eql(appdir: "/Applications")
      expect(dsl.entries[0].name).to eql("homebrew/cask")
      expect(dsl.entries[1].name).to eql("telemachus/brew")
      expect(dsl.entries[1].options).to \
        eql(clone_target: "https://telemachus@bitbucket.org/telemachus/brew.git", pin: true)
      expect(dsl.entries[2].name).to eql("imagemagick")
      expect(dsl.entries[3].name).to eql("mysql@5.6")
      expect(dsl.entries[3].options).to eql(restart_service: true, link: true, conflicts_with: ["mysql"])
      expect(dsl.entries[4].name).to eql("emacs")
      expect(dsl.entries[4].options).to eql(args: ["with-cocoa", "with-gnutls"])
      expect(dsl.entries[5].name).to eql("google-chrome")
      expect(dsl.entries[6].name).to eql("java")
      expect(dsl.entries[7].name).to eql("firefox")
      expect(dsl.entries[7].options).to eql(args: { appdir: "~/my-apps/Applications" }, full_name: "firefox")
      expect(dsl.entries[8].name).to eql("1Password")
      expect(dsl.entries[8].options).to eql(id: 443_987_910)
      expect(dsl.entries[9].name).to eql("whalebrew/wget")
    end
  end

  context "with invalid input" do
    it "handles completely invalid code" do
      expect { described_class.new "abcdef" }.to raise_error(RuntimeError)
    end

    it "handles valid commands but with invalid options" do
      expect { described_class.new "brew 1" }.to raise_error(RuntimeError)
      expect { described_class.new "cask 1" }.to raise_error(RuntimeError)
      expect { described_class.new "tap 1" }.to raise_error(RuntimeError)
      expect { described_class.new "cask_args ''" }.to raise_error(RuntimeError)
    end

    it "errors on bad options" do
      expect { described_class.new "brew 'foo', ['bad_option']" }.to raise_error(RuntimeError)
      expect { described_class.new "cask 'foo', ['bad_option']" }.to raise_error(RuntimeError)
      expect { described_class.new "tap 'foo', ['bad_clone_target']" }.to raise_error(RuntimeError)
    end
  end

  it ".sanitize_brew_name" do
    expect(described_class.send(:sanitize_brew_name, "homebrew/homebrew/foo")).to eql("foo")
    expect(described_class.send(:sanitize_brew_name, "homebrew/homebrew-bar/foo")).to eql("homebrew/bar/foo")
    expect(described_class.send(:sanitize_brew_name, "homebrew/bar/foo")).to eql("homebrew/bar/foo")
    expect(described_class.send(:sanitize_brew_name, "foo")).to eql("foo")
  end

  it ".sanitize_tap_name" do
    expect(described_class.send(:sanitize_tap_name, "homebrew/homebrew-foo")).to eql("homebrew/foo")
    expect(described_class.send(:sanitize_tap_name, "homebrew/foo")).to eql("homebrew/foo")
  end

  it ".sanitize_cask_name" do
    allow_any_instance_of(Object).to receive(:opoo)
    expect(described_class.send(:sanitize_cask_name, "homebrew/cask-versions/adoptopenjdk8")).to eql("adoptopenjdk8")
    expect(described_class.send(:sanitize_cask_name, "adoptopenjdk8")).to eql("adoptopenjdk8")
  end

  it ".pluralize_dependency" do
    expect(described_class.send(:pluralize_dependency, 0)).to eql("dependencies")
    expect(described_class.send(:pluralize_dependency, 1)).to eql("dependency")
    expect(described_class.send(:pluralize_dependency, 5)).to eql("dependencies")
  end
end
