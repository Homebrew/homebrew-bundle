require "spec_helper"

describe Bundle::BrewDumper do
  context "when brew is not installed" do
    it "raises an error" do
      allow(Bundle).to receive(:brew_installed?).and_return(false)
      expect { Bundle::BrewDumper.new }.to raise_error(RuntimeError)
    end
  end

  context "when no formula is installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewDumper).to receive(:`).and_return("[]")
    end
    subject { Bundle::BrewDumper.new }

    it "returns empty list" do
      expect(subject.formulae).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "formulae `foo` and `bar` are installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewDumper).to receive(:`)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "full_name" => "homebrew/tap/foo",
          "versions" => { "stable" => "1.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [{ "version" => "1.0", "used_options" => [] }],
          "linked_keg" => "1.0",
          "dependencies" => [],
          "requirements" => [],
        },
        {
          "name" => "bar",
          "full_name" => "bar",
          "versions" => { "stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [{ "version" => "2.0", "used_options" => ["--with-a", "--with-b"] }],
          "linked_keg" => "2.0",
          "dependencies" => [],
          "requirements" => [],
        },
      ]
    end
    subject { Bundle::BrewDumper.new }

    it "returns foo and bar with their information" do
      expect(subject.formulae).to contain_exactly *[
        {
          :name => "foo",
          :full_name => "homebrew/tap/foo",
          :args => [],
          :version => "1.0",
          :dependencies => [],
          :requirements => [],
        },
        {
          :name => "bar",
          :full_name => "bar",
          :args => ["with-a", "with-b"],
          :version => "2.0",
          :dependencies => [],
          :requirements => [],
        },
      ]
    end

    it "dumps as foo and bar with args" do
      expect(subject.to_s).to eql("brew 'bar', args: ['with-a', 'with-b']\nbrew 'homebrew/tap/foo'")
    end
  end

  context "HEAD and devel formulae are installed" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewDumper).to receive(:`)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "full_name" => "foo",
          "versions" => { "stable" => "1.0", "bottle" => false, "devel" => "1.1beta", "head" => "HEAD" },
          "installed" => [{ "version" => "1.1beta", "used_options" => [] }],
          "linked_keg" => "1.1beta",
          "dependencies" => [],
          "requirements" => [],
        },
        {
          "name" => "bar",
          "full_name" => "homebrew/tap/bar",
          "versions" => { "stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [{ "version" => "HEAD", "used_options" => [] }],
          "linked_keg" => "HEAD",
          "dependencies" => [],
          "requirements" => [],
        },
      ]
    end
    subject { Bundle::BrewDumper.new.formulae }

    it "returns with args `devel` and `HEAD`" do
      expect(subject[0][:args]).to include("devel")
      expect(subject[1][:args]).to include("HEAD")
    end
  end

  context "A formula link to the old keg" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewDumper).to receive(:`)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "full_name" => "homebrew/tap/foo",
          "versions" => { "stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [
            { "version" => "1.0", "used_options" => [] },
            { "version" => "2.0", "used_options" => [] },
          ],
          "linked_keg" => "1.0",
          "dependencies" => [],
          "requirements" => [],
        }
      ]
    end
    subject { Bundle::BrewDumper.new.formulae }

    it "returns with linked keg" do
      expect(subject[0][:version]).to eql("1.0")
    end
  end

  context "A formula with no linked keg" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewDumper).to receive(:`)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "full_name" => "homebrew/tap/foo",
          "versions" => { "stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [
            { "version" => "1.0", "used_options" => [] },
            { "version" => "2.0", "used_options" => [] },
          ],
          "linked_keg" => nil,
          "dependencies" => [],
          "requirements" => [],
        }
      ]
    end
    subject { Bundle::BrewDumper.new.formulae }

    it "returns with last one" do
      expect(subject[0][:version]).to eql("2.0")
    end
  end

  context "several formulae with dependant relations" do
    before do
      allow(Bundle).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Bundle::BrewDumper).to receive(:`)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "a",
          "full_name" => "a",
          "versions" => { "stable" => "1.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [{ "version" => "1.0", "used_options" => [] }],
          "linked_keg" => "1.0",
          "dependencies" => ["b"],
          "requirements" => [],
        },
        {
          "name" => "b",
          "full_name" => "b",
          "versions" => { "stable" => "1.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [{ "version" => "1.0", "used_options" => [] }],
          "linked_keg" => "1.0",
          "dependencies" => [],
          "requirements" => [{ "name" => "foo", "default_formula" => "c", "cask" => "bar" }],
        },
        {
          "name" => "c",
          "full_name" => "homebrew/tap/c",
          "versions" => { "stable" => "1.0", "bottle" => false, "devel" => nil, "head" => "HEAD" },
          "installed" => [{ "version" => "1.0", "used_options" => [] }],
          "linked_keg" => "1.0",
          "dependencies" => [],
          "requirements" => [],
        },
      ]
    end
    subject { Bundle::BrewDumper.new }

    it "returns formulae with correct order" do
      expect(subject.formulae.map { |f| f[:name] }).to eq %w[c b a]
    end

    it "returns all the cask requirements" do
      expect(subject.expand_cask_requirements).to eq %w[bar]
    end
  end
end
