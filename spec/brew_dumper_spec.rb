require "spec_helper"
require "tsort"

describe Bundle::BrewDumper do
  context "when no formula is installed" do
    before do
      Bundle::BrewDumper.reset!
    end
    subject { Bundle::BrewDumper }

    it "returns empty list" do
      expect(subject.formulae).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "when Homebrew returns JSON with a malformed linked_keg" do
    before do
      Bundle::BrewDumper.reset!
      allow(Formula).to receive(:[]).and_return(nil)
      allow(Formula).to receive(:installed).and_return(
        [{
          "name" => "foo",
          "full_name" => "homebrew/tap/foo",
          "desc" => "",
          "homepage" => "",
          "oldname" => nil,
          "aliases" => [],
          "versions" => { "stable" => "1.0", "bottle" => false },
          "revision" => 0,
          "installed" => [{
            "version" => "1.0",
            "used_options" => [],
            "built_as_bottle" => nil,
            "poured_from_bottle" => true,
          }],
          "linked_keg" => "fish",
          "keg_only" => nil,
          "dependencies" => [],
          "recommended_dependencies" => [],
          "optional_dependencies" => [],
          "build_dependencies" => [],
          "conflicts_with" => [],
          "caveats" => nil,
          "requirements" => [],
          "options" => [],
          "bottle" => {},
        }],
      )
    end
    subject { Bundle::BrewDumper }

    it "returns no version" do
      expect(subject.formulae).to contain_exactly(
        name: "foo",
        full_name: "homebrew/tap/foo",
        oldname: nil,
        aliases: [],
        args: [],
        version: nil,
        installed_as_dependency?: false,
        installed_on_request?: false,
        dependencies: [],
        recommended_dependencies: [],
        optional_dependencies: [],
        build_dependencies: [],
        requirements: [],
        conflicts_with: [],
        pinned?: false,
        outdated?: false,
      )
    end
  end

  context "formulae `foo` and `bar` are installed" do
    before do
      Bundle::BrewDumper.reset!
      allow(Formula).to receive(:[]).and_return(
        "name" => "foo",
        "full_name" => "homebrew/tap/foo",
        "desc" => "",
        "homepage" => "",
        "oldname" => nil,
        "aliases" => [],
        "versions" => { "stable" => "1.0", "bottle" => false },
        "revision" => 0,
        "installed" => [{
          "version" => "1.0",
          "used_options" => [],
          "built_as_bottle" => nil,
          "poured_from_bottle" => true,
        }],
        "linked_keg" => "1.0",
        "keg_only" => nil,
        "dependencies" => [],
        "recommended_dependencies" => [],
        "optional_dependencies" => [],
        "build_dependencies" => [],
        "conflicts_with" => [],
        "caveats" => nil,
        "requirements" => [],
        "options" => [],
        "bottle" => {},
      )
      allow(Formula).to receive(:installed).and_return(
        [
          {
            "name" => "foo",
            "full_name" => "homebrew/tap/foo",
            "desc" => "",
            "homepage" => "",
            "oldname" => nil,
            "aliases" => [],
            "versions" => { "stable" => "1.0", "bottle" => false },
            "revision" => 0,
            "installed" => [{
              "version" => "1.0",
              "used_options" => [],
              "built_as_bottle" => nil,
              "poured_from_bottle" => true,
              "installed_as_dependency" => false,
              "installed_on_request" => true,
              "runtime_dependencies" => [],
            }],
            "linked_keg" => "1.0",
            "keg_only" => nil,
            "dependencies" => [],
            "recommended_dependencies" => [],
            "optional_dependencies" => [],
            "build_dependencies" => [],
            "conflicts_with" => [],
            "caveats" => nil,
            "requirements" => [],
            "options" => [],
            "bottle" => {},
          },
          {
            "name" => "bar",
            "full_name" => "bar",
            "desc" => "",
            "homepage" => "",
            "oldname" => nil,
            "aliases" => [],
            "versions" => { "stable" => "2.1", "bottle" => false },
            "revision" => 0,
            "installed" => [{
              "version" => "2.0",
              "used_options" => ["--with-a", "--with-b"],
              "built_as_bottle" => nil,
              "poured_from_bottle" => true,
              "installed_as_dependency" => true,
              "installed_on_request" => true,
              "runtime_dependencies" => [],
            }],
            "linked_keg" => nil,
            "keg_only" => nil,
            "dependencies" => [],
            "recommended_dependencies" => [],
            "optional_dependencies" => [],
            "build_dependencies" => [],
            "conflicts_with" => [],
            "caveats" => nil,
            "requirements" => [],
            "options" => [],
            "bottle" => {},
            "pinned" => true,
            "outdated" => true,
          },
        ],
      )
    end
    subject { Bundle::BrewDumper }

    it "returns foo and bar with their information" do
      expect(subject.formulae).to contain_exactly(
        {
          name: "foo",
          full_name: "homebrew/tap/foo",
          oldname: nil,
          aliases: [],
          args: [],
          version: "1.0",
          installed_as_dependency?: false,
          installed_on_request?: true,
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        name: "bar",
        full_name: "bar",
        oldname: nil,
        aliases: [],
        args: ["with-a", "with-b"],
        version: "2.0",
        installed_as_dependency?: true,
        installed_on_request?: true,
        dependencies: [],
        recommended_dependencies: [],
        optional_dependencies: [],
        build_dependencies: [],
        requirements: [],
        conflicts_with: [],
        pinned?: true,
        outdated?: true,
      )
    end

    it "dumps as foo and bar with args" do
      expect(subject.dump).to eql("brew \"bar\", args: [\"with-a\", \"with-b\"]\nbrew \"homebrew/tap/foo\"")
    end

    it "formula_info returns the formula" do
      expect(subject.formula_info("foo")[:name]).to eql("foo")
    end
  end

  context "HEAD and devel formulae are installed" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          name: "foo",
          full_name: "foo",
          aliases: [],
          args: ["devel"],
          version: "1.1beta",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        {
          name: "bar",
          full_name: "homebrew/tap/bar",
          aliases: [],
          args: ["HEAD"],
          version: "HEAD",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
      ]
    end
    subject { Bundle::BrewDumper.formulae }

    it "returns with args `devel` and `HEAD`" do
      expect(subject[0][:args]).to include("devel")
      expect(subject[1][:args]).to include("HEAD")
    end
  end

  context "A formula link to the old keg" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          name: "foo",
          full_name: "homebrew/tap/foo",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
      ]
    end
    subject { Bundle::BrewDumper.formulae }

    it "returns with linked keg" do
      expect(subject[0][:version]).to eql("1.0")
    end
  end

  context "A formula with no linked keg" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          name: "foo",
          full_name: "homebrew/tap/foo",
          aliases: [],
          args: [],
          version: "2.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
      ]
    end
    subject { Bundle::BrewDumper.formulae }

    it "returns with last one" do
      expect(subject[0][:version]).to eql("2.0")
    end
  end

  context "several formulae with dependant relations" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          name: "a",
          full_name: "a",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: ["b"],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        {
          name: "b",
          full_name: "b",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [{ "name" => "foo", "default_formula" => "c", "cask" => "bar" }],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        {
          name: "c",
          full_name: "homebrew/tap/c",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
      ]
    end
    subject { Bundle::BrewDumper }

    it "returns formulae with correct order" do
      expect(subject.formulae.map { |f| f[:name] }).to eq %w[c b a]
    end

    it "returns all the cask requirements" do
      expect(subject.cask_requirements).to eq %w[bar]
    end
  end

  context "formulae with unsorted dependencies" do
    before do
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return [
        {
          name: "a",
          full_name: "a",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: ["b", "d", "c"],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        {
          name: "b",
          full_name: "b",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        {
          name: "c",
          full_name: "c",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
        {
          name: "d",
          full_name: "d",
          aliases: [],
          args: [],
          version: "1.0",
          dependencies: [],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        },
      ]
    end
    subject { Bundle::BrewDumper }

    it "returns formulae with correct order" do
      expect(subject.formulae.map { |f| f[:name] }).to eq %w[b c d a]
    end

    context "when performing a topological sort" do
      before do
        allow(Bundle::BrewDumper::Topo).to \
          receive(:new).and_raise(TSort::Cyclic)
        allow_any_instance_of(String).to receive(:undent)
        allow_any_instance_of(Object).to receive(:odie) { raise }
      end

      it "dies on cyclic exceptions" do
        expect { subject.formulae }.to raise_error(TSort::Cyclic)
      end
    end
  end

  context "when order of args for a formula is different in different environment" do
    it "dumps args in same order" do
      formula_info = [
        [{
          name: "a",
          full_name: "a",
          aliases: [],
          args: ["with-1", "with-2"],
          version: "1.0",
          dependencies: ["b"],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        }],
        [{
          name: "a",
          full_name: "a",
          aliases: [],
          args: ["with-2", "with-1"],
          version: "1.0",
          dependencies: ["b"],
          recommended_dependencies: [],
          optional_dependencies: [],
          build_dependencies: [],
          requirements: [],
          conflicts_with: [],
          pinned?: false,
          outdated?: false,
        }],
      ]
      dump_lines = formula_info.map do |info|
        Bundle::BrewDumper.reset!
        allow(Bundle::BrewDumper).to receive(:formulae_info).and_return(info)
        Bundle::BrewDumper.dump
      end
      expect(dump_lines[0]).to eql(dump_lines[1])
    end
  end

  context "#formula_oldnames" do
    it "works" do
      formula_info = [{
        name: "a",
        full_name: "homebrew/versions/a",
        oldname: "aold",
        aliases: [],
        args: ["with-1", "with-2"],
        version: "1.0",
        dependencies: ["b"],
        recommended_dependencies: [],
        optional_dependencies: [],
        build_dependencies: [],
        requirements: [],
        conflicts_with: [],
        pinned?: false,
        outdated?: false,
      }]
      Bundle::BrewDumper.reset!
      allow(Bundle::BrewDumper).to receive(:formulae_info).and_return(formula_info)
      expect(Bundle::BrewDumper.formula_oldnames["aold"]).to eql "homebrew/versions/a"
    end
  end
end
