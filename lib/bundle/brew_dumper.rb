# frozen_string_literal: true

require "json"
require "tsort"

module Bundle
  # TODO: refactor into multiple modules
  module BrewDumper
    module_function

    def reset!
      Bundle::BrewServices.reset!
      @formulae = nil
      @formula_aliases = nil
      @formula_oldnames = nil
    end

    def formulae
      @formulae ||= begin
        @formulae = formulae_info
        sort!
      end
    end

    def dump(describe: false, no_restart: false)
      requested_formula = formulae.select do |f|
        f[:installed_on_request?] || !f[:installed_as_dependency?]
      end
      requested_formula.map do |f|
        brewline = ""
        brewline += desc_comment(f[:desc]) if describe && f[:desc]
        brewline += "brew \"#{f[:full_name]}\""
        args = f[:args].map { |arg| "\"#{arg}\"" }.sort.join(", ")
        brewline += ", args: [#{args}]" unless f[:args].empty?
        brewline += ", restart_service: true" if !no_restart && BrewServices.started?(f[:full_name])
        brewline += ", link: #{f[:link?]}" unless f[:link?].nil?
        brewline
      end.join("\n")
    end

    def desc_comment(desc)
      desc.split("\n").map { |s| "# #{s}\n" }.join
    end

    def cask_requirements
      formulae.flat_map do |f|
        f[:requirements].map { |req| req["cask"]&.split("/")&.last }
      end.compact.uniq
    end

    def formula_names
      formulae.map { |f| f[:name] }
    end

    def formula_oldnames
      return @formula_oldnames if @formula_oldnames

      @formula_oldnames = {}
      formulae.each do |f|
        oldname = f[:oldname]
        next unless oldname

        @formula_oldnames[oldname] = f[:full_name]
        if f[:full_name].include? "/" # tap formula
          tap_name = f[:full_name].rpartition("/").first
          @formula_oldnames["#{tap_name}/#{oldname}"] = f[:full_name]
        end
      end
      @formula_oldnames
    end

    def formula_aliases
      return @formula_aliases if @formula_aliases

      @formula_aliases = {}
      formulae.each do |f|
        aliases = f[:aliases]
        next if !aliases || aliases.empty?

        aliases.each do |a|
          @formula_aliases[a] = f[:full_name]
          if f[:full_name].include? "/" # tap formula
            tap_name = f[:full_name].rpartition("/").first
            @formula_aliases["#{tap_name}/#{a}"] = f[:full_name]
          end
        end
      end
      @formula_aliases
    end

    def formula_info(name)
      @formula_info_name ||= {}
      @formula_info_name[name] ||= begin
        require "formula"
        formula_inspector formula_hash(Formula[name])
      end
    rescue NameError, ArgumentError, ScriptError,
           FormulaUnavailableError => e
      opoo "'#{name}' formula is unreadable: #{e}"
    end

    def formulae_info
      require "formula"
      Formula.installed.map do |f|
        formula_inspector formula_hash(f)
      end.compact
    rescue NameError, ArgumentError, ScriptError,
           FormulaUnavailableError => e
      opoo "Unreadable formula: #{e}"
    end

    def formula_hash(formula)
      formula.to_hash
    rescue NameError, ArgumentError, ScriptError,
           FormulaUnavailableError => e
      opoo "'#{formula.name}' formula is unreadable: #{e}"
    end

    def formula_inspector(formula)
      return unless formula

      installed = formula["installed"]
      link = nil
      if formula["linked_keg"].nil?
        keg = installed.last
        link = false unless formula["keg_only"]
      else
        keg = installed.find { |k| formula["linked_keg"] == k["version"] }
        link = true if formula["keg_only"]
      end

      if keg
        args = keg["used_options"].to_a.map { |option| option.delete_prefix("--") }
        args << "HEAD" if keg["version"].to_s.start_with?("HEAD")
        args << "devel" if keg["version"].to_s.gsub(/_\d+$/, "") == formula["versions"]["devel"]
        args.uniq!
        version = keg["version"]
        installed_as_dependency = keg["installed_as_dependency"] || false
        installed_on_request = keg["installed_on_request"] || false
        poured_from_bottle = keg["poured_from_bottle"] || false
        runtime_dependencies = if (deps = keg["runtime_dependencies"])
          deps.map do |dep|
            full_name = dep["full_name"]
            next unless full_name

            full_name.split("/").last
          end.compact
        end
      else
        args = []
        version = nil
        installed_as_dependency = false
        installed_on_request = false
        runtime_dependencies = nil
        poured_from_bottle = false
      end

      {
        name:                     formula["name"],
        desc:                     formula["desc"],
        oldname:                  formula["oldname"],
        full_name:                formula["full_name"],
        aliases:                  formula["aliases"],
        args:                     args,
        version:                  version,
        installed_as_dependency?: installed_as_dependency,
        installed_on_request?:    installed_on_request,
        dependencies:             (runtime_dependencies || formula["dependencies"]),
        recommended_dependencies: formula["recommended_dependencies"],
        optional_dependencies:    formula["optional_dependencies"],
        build_dependencies:       formula["build_dependencies"],
        requirements:             formula["requirements"],
        conflicts_with:           formula["conflicts_with"],
        pinned?:                  (formula["pinned"] || false),
        outdated?:                (formula["outdated"] || false),
        link?:                    link,
        poured_from_bottle?:      poured_from_bottle,
      }
    end

    class Topo < Hash
      include TSort
      alias tsort_each_node each_key
      def tsort_each_child(node, &block)
        fetch(node).sort.each(&block)
      end
    end

    def sort!
      # Step 1: Sort by formula full name while putting tap formulae behind core formulae.
      #         So we can have a nicer output.
      @formulae.sort! do |a, b|
        if !a[:full_name].include?("/") && b[:full_name].include?("/")
          -1
        elsif a[:full_name].include?("/") && !b[:full_name].include?("/")
          1
        else
          a[:full_name] <=> b[:full_name]
        end
      end

      # Step 2: Sort by formula dependency topology.
      topo = Topo.new
      @formulae.each do |f|
        deps = (
          f[:dependencies] \
          + f[:requirements].map { |req| req["default_formula"] }.compact \
          - f[:optional_dependencies] \
          - f[:build_dependencies] \
        ).uniq
        topo[f[:full_name]] = deps.map do |dep|
          ff = @formulae.find { |formula| [formula[:name], formula[:full_name]].include?(dep) }
          next unless ff

          ff[:full_name]
        end.compact
      end
      @formulae = topo.tsort.map { |name| @formulae.find { |formula| formula[:full_name] == name } }
    rescue TSort::Cyclic => e
      e.message =~ /\["(.*)", "(.*)"\]/
      cycle_first = Regexp.last_match(1)
      cycle_last = Regexp.last_match(2)
      odie e.message if !cycle_first || !cycle_last

      odie <<~EOS
        Formulae dependency graph sorting failed (likely due to a circular dependency):
        #{cycle_first}: #{topo[cycle_first]}
        #{cycle_last}: #{topo[cycle_last]}
        Please run the following commands and try again:
          brew update
          brew uninstall --ignore-dependencies --force #{cycle_first} #{cycle_last}
          brew install #{cycle_first} #{cycle_last}
      EOS
    end
  end
end
