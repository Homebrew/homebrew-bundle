# frozen_string_literal: true

require "spec_helper"
require "tsort"

describe Bundle::BrewDumper do
  subject(:dumper) { described_class }

  context "when no formula is installed" do
    before do
      described_class.reset!
    end

    it "returns empty list" do
      expect(dumper.formulae).to be_empty
    end

    it "dumps as empty string" do
      expect(dumper.dump).to eql("")
    end
  end

  context "when Homebrew returns JSON with a malformed linked_keg" do
    installed_data = [{
      "name"                     => "foo",
      "full_name"                => "homebrew/tap/foo",
      "desc"                     => "",
      "homepage"                 => "",
      "oldname"                  => nil,
      "aliases"                  => [],
      "versions"                 => { "stable" => "1.0", "bottle" => false },
      "revision"                 => 0,
      "installed"                => [{
        "version"            => "1.0",
        "used_options"       => [],
        "built_as_bottle"    => nil,
        "poured_from_bottle" => true,
      }],
      "linked_keg"               => "fish",
      "keg_only"                 => nil,
      "dependencies"             => [],
      "recommended_dependencies" => [],
      "optional_dependencies"    => [],
      "build_dependencies"       => [],
      "conflicts_with"           => [],
      "caveats"                  => nil,
      "requirements"             => [],
      "options"                  => [],
      "bottle"                   => {},
    }]

    parsed_data = {
      name:                     "foo",
      full_name:                "homebrew/tap/foo",
      desc:                     "",
      oldname:                  nil,
      aliases:                  [],
      args:                     [],
      version:                  nil,
      installed_as_dependency?: false,
      installed_on_request?:    false,
      dependencies:             [],
      recommended_dependencies: [],
      optional_dependencies:    [],
      build_dependencies:       [],
      requirements:             [],
      conflicts_with:           [],
      pinned?:                  false,
      outdated?:                false,
      link?:                    nil,
      poured_from_bottle?:      false,
    }

    before do
      described_class.reset!
      allow(Formula).to receive(:[]).and_return(nil)
      allow(Formula).to receive(:installed).and_return(installed_data)
    end

    it "returns no version" do
      expect(dumper.formulae).to contain_exactly(parsed_data)
    end
  end

  context "formulae `foo` and `bar` are installed" do
    before do
      described_class.reset!
      allow(Formula).to receive(:[]).and_return(
        "name"                     => "foo",
        "full_name"                => "homebrew/tap/foo",
        "desc"                     => "",
        "homepage"                 => "",
        "oldname"                  => nil,
        "aliases"                  => [],
        "versions"                 => { "stable" => "1.0", "bottle" => false },
        "revision"                 => 0,
        "installed"                => [{
          "version"              => "1.0",
          "used_options"         => [],
          "built_as_bottle"      => nil,
          "poured_from_bottle"   => true,
          "runtime_dependencies" => [],
        }],
        "linked_keg"               => "1.0",
        "keg_only"                 => nil,
        "dependencies"             => [],
        "recommended_dependencies" => [],
        "optional_dependencies"    => [],
        "build_dependencies"       => [],
        "runtime_dependencies"     => [],
        "conflicts_with"           => [],
        "caveats"                  => nil,
        "requirements"             => [],
        "options"                  => [],
        "bottle"                   => {},
      )
      allow(Formula).to receive(:installed).and_return(
        [
          {
            "name"                     => "foo",
            "full_name"                => "homebrew/tap/foo",
            "desc"                     => "",
            "homepage"                 => "",
            "oldname"                  => nil,
            "aliases"                  => [],
            "versions"                 => { "stable" => "1.0", "bottle" => false },
            "revision"                 => 0,
            "installed"                => [{
              "version"                 => "1.0",
              "used_options"            => [],
              "built_as_bottle"         => nil,
              "poured_from_bottle"      => true,
              "installed_as_dependency" => false,
              "installed_on_request"    => true,
              "runtime_dependencies"    => [],
            }],
            "linked_keg"               => "1.0",
            "keg_only"                 => nil,
            "dependencies"             => [],
            "recommended_dependencies" => [],
            "optional_dependencies"    => [],
            "build_dependencies"       => [],
            "runtime_dependencies"     => [],
            "conflicts_with"           => [],
            "caveats"                  => nil,
            "requirements"             => [],
            "options"                  => [],
            "bottle"                   => {},
          },
          {
            "name"                     => "bar",
            "full_name"                => "bar",
            "desc"                     => "",
            "homepage"                 => "",
            "oldname"                  => nil,
            "aliases"                  => [],
            "versions"                 => { "stable" => "2.1", "bottle" => false },
            "revision"                 => 0,
            "installed"                => [{
              "version"                 => "2.0",
              "used_options"            => ["--with-a", "--with-b"],
              "built_as_bottle"         => nil,
              "poured_from_bottle"      => false,
              "installed_as_dependency" => true,
              "installed_on_request"    => true,
              "runtime_dependencies"    => [{
                "full_name" => "baz",
                "version"   => "1.0",
              }],
            }],
            "linked_keg"               => nil,
            "keg_only"                 => nil,
            "dependencies"             => [],
            "recommended_dependencies" => [],
            "optional_dependencies"    => [],
            "build_dependencies"       => [],
            "conflicts_with"           => [],
            "caveats"                  => nil,
            "requirements"             => [],
            "options"                  => [],
            "bottle"                   => {},
            "pinned"                   => true,
            "outdated"                 => true,
          },
        ],
      )
    end

    it "returns foo and bar with their information" do # rubocop:disable RSpec/ExampleLength
      expect(dumper.formulae).to contain_exactly(
        {
          name:                     "foo",
          full_name:                "homebrew/tap/foo",
          desc:                     "",
          oldname:                  nil,
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          installed_as_dependency?: false,
          installed_on_request?:    true,
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
          link?:                    nil,
          poured_from_bottle?:      true,
        },
        name:                     "bar",
        full_name:                "bar",
        desc:                     "",
        oldname:                  nil,
        aliases:                  [],
        args:                     ["with-a", "with-b"],
        version:                  "2.0",
        installed_as_dependency?: true,
        installed_on_request?:    true,
        dependencies:             ["baz"],
        recommended_dependencies: [],
        optional_dependencies:    [],
        build_dependencies:       [],
        requirements:             [],
        conflicts_with:           [],
        pinned?:                  true,
        outdated?:                true,
        link?:                    false,
        poured_from_bottle?:      false,
      )
    end

    it "dumps as foo and bar with args and link" do
      expect(dumper.dump).to \
        eql("brew \"bar\", args: [\"with-a\", \"with-b\"], link: false\nbrew \"homebrew/tap/foo\"")
    end

    it "formula_info returns the formula" do
      expect(dumper.formula_info("foo")[:name]).to eql("foo")
    end
  end

  context "HEAD and devel formulae are installed" do
    subject(:formulae_list) { described_class.formulae }

    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "foo",
          full_name:                "foo",
          aliases:                  [],
          args:                     ["devel"],
          version:                  "1.1beta",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "bar",
          full_name:                "homebrew/tap/bar",
          aliases:                  [],
          args:                     ["HEAD"],
          version:                  "HEAD",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "returns with args `devel` and `HEAD`" do
      expect(formulae_list[0][:args]).to include("devel")
      expect(formulae_list[1][:args]).to include("HEAD")
    end
  end

  context "A formula link to the old keg" do
    subject(:formulae_list) { described_class.formulae }

    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "foo",
          full_name:                "homebrew/tap/foo",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "returns with linked keg" do
      expect(formulae_list[0][:version]).to eql("1.0")
    end
  end

  context "A formula with no linked keg" do
    subject(:formulae_list) { described_class.formulae }

    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "foo",
          full_name:                "homebrew/tap/foo",
          aliases:                  [],
          args:                     [],
          version:                  "2.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "returns with last one" do
      expect(formulae_list[0][:version]).to eql("2.0")
    end
  end

  context "several formulae with dependant relations" do
    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "a",
          full_name:                "a",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             ["b"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "b",
          full_name:                "b",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [{ "name" => "foo", "default_formula" => "c", "cask" => "bar" }],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "c",
          full_name:                "homebrew/tap/c",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "returns formulae with correct order" do
      expect(dumper.formulae.map { |f| f[:name] }).to eq %w[c b a]
    end

    it "returns all the cask requirements" do
      expect(dumper.cask_requirements).to eq %w[bar]
    end
  end

  context "formulae with unsorted dependencies" do
    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "a",
          full_name:                "a",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             ["b", "d", "c"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "b",
          full_name:                "b",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "c",
          full_name:                "c",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "d",
          full_name:                "d",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "returns formulae with correct order" do
      expect(dumper.formulae.map { |f| f[:name] }).to eq %w[b c d a]
    end

    context "when performing a topological sort" do
      before do
        allow_any_instance_of(Bundle::BrewDumper::Topo).to \
          receive(:tsort)
          .and_raise(TSort::Cyclic, "topological sort failed: [\"libidn2\", \"wget\"]")
        allow_any_instance_of(Object).to receive(:odie) { raise }
      end

      it "dies on cyclic exceptions" do
        expect { dumper.formulae }.to raise_error(TSort::Cyclic)
      end
    end
  end

  context "when `describe` is false" do
    subject(:dump) { described_class.dump(describe: false) }

    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "a",
          full_name:                "a",
          desc:                     "z",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             ["b", "d", "c"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "b",
          full_name:                "b",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "does not output a comment with dependency description" do
      expect(dump).not_to include("#")
    end
  end

  context "when `describe` is true" do
    subject(:dump) { described_class.dump(describe: true) }

    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "a",
          full_name:                "a",
          desc:                     "z",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             ["b", "d", "c"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "q",
          full_name:                "q",
          desc:                     "q\nq",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             ["a", "b"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "b",
          full_name:                "b",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
    end

    it "outputs a comment on the line before a dependency with a description" do
      expect(dump).to include("# z")
    end

    it "outputs a comment for each line in the formula's desc before a dependency with a description" do
      expect(dump).to include("# q\n# q")
    end

    it "does not output a comment if a formula lacks a description" do
      lines_with_comments = dump.split.select { |line| line.include?("#") }
      expect(lines_with_comments.size).to eq(3)
    end
  end

  describe "restarting" do
    before do
      described_class.reset!
      allow(described_class).to receive(:formulae_info).and_return [
        {
          name:                     "a",
          full_name:                "a",
          desc:                     "z",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             ["b", "d", "c"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
        {
          name:                     "b",
          full_name:                "b",
          aliases:                  [],
          args:                     [],
          version:                  "1.0",
          dependencies:             [],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        },
      ]
      allow(Bundle::BrewServices).to receive(:started?).with("a").and_return(true)
      allow(Bundle::BrewServices).to receive(:started?).with("b").and_return(false)
    end

    it "adds restart_service for started services" do
      expect(described_class.dump).to include('brew "a", restart_service: true')
    end

    it "does not add restart_service for stopped services" do
      expect(described_class.dump).to include('brew "b"')
      expect(described_class.dump).not_to include('brew "b", restart_service: true')
    end

    context "when `no_restart` is true" do
      subject(:dump) { described_class.dump(no_restart: true) }

      it "does not add a restart_service bit if the service is running" do
        expect(dump).not_to include("restart_service")
      end
    end
  end

  context "when order of args for a formula is different in different environment" do
    let(:formula_info) do
      [
        [{
          name:                     "a",
          full_name:                "a",
          aliases:                  [],
          args:                     ["with-1", "with-2"],
          version:                  "1.0",
          dependencies:             ["b"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        }],
        [{
          name:                     "a",
          full_name:                "a",
          aliases:                  [],
          args:                     ["with-2", "with-1"],
          version:                  "1.0",
          dependencies:             ["b"],
          recommended_dependencies: [],
          optional_dependencies:    [],
          build_dependencies:       [],
          requirements:             [],
          conflicts_with:           [],
          pinned?:                  false,
          outdated?:                false,
        }],
      ]
    end

    let(:dump_lines) do
      formula_info.map do |info|
        described_class.reset!
        allow(described_class).to receive(:formulae_info).and_return(info)
        described_class.dump
      end
    end

    it "dumps args in same order" do
      expect(dump_lines[0]).to eql(dump_lines[1])
    end
  end

  describe "#formula_oldnames" do
    before do
      described_class.reset!
      formula_info = [{
        name:                     "a",
        full_name:                "homebrew/versions/a",
        oldname:                  "aold",
        aliases:                  [],
        args:                     ["with-1", "with-2"],
        version:                  "1.0",
        dependencies:             ["b"],
        recommended_dependencies: [],
        optional_dependencies:    [],
        build_dependencies:       [],
        requirements:             [],
        conflicts_with:           [],
        pinned?:                  false,
        outdated?:                false,
      }]
      allow(described_class).to receive(:formulae_info).and_return(formula_info)
    end

    it "works" do
      expect(described_class.formula_oldnames["aold"]).to eql "homebrew/versions/a"
    end
  end

  describe "#formula_info" do
    it "handles formula syntax errors" do
      allow(Formula).to receive(:[]).and_raise(NoMethodError)
      expect(described_class).to receive(:opoo).once
      described_class.instance_variable_set("@formula_info_name", nil)
      described_class.formula_info("foo")
    end
  end

  describe "#formulae_info" do
    it "handles formula syntax errors" do
      allow(Formula).to receive(:installed).and_raise(NoMethodError)
      expect(described_class).to receive(:opoo).once
      described_class.formulae_info
    end
  end

  describe "#formula_hash" do
    let(:f) { OpenStruct.new }

    it "handles formula syntax errors" do
      allow(f).to receive(:to_hash).and_raise(NoMethodError)
      expect(described_class).to receive(:opoo).once
      described_class.formula_hash(f)
    end
  end
end
