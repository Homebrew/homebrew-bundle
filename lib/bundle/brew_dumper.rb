require "json"
require "tsort"

# rubocop:disable Metrics/ModuleLength
module Bundle
  module BrewDumper
    module_function

    def reset!
      Bundle::BrewServices.reset!
      @formulae = nil
      @formula_aliases = nil
    end

    def formulae
      @formulae ||= begin
        @formulae = formulae_info
        sort!
      end
    end

    def dump
      formulae.map do |f|
        brewline = "brew '#{f[:full_name]}'"
        args = f[:args].map { |arg| "'#{arg}'" }.sort.join(", ")
        brewline += ", args: [#{args}]" unless f[:args].empty?
        brewline += ", restart_service: true" if BrewServices.started?(f[:full_name])
        brewline
      end.join("\n")
    end

    def cask_requirements
      formulae.map { |f| f[:requirements].map { |req| req["cask"] } }.flatten.compact.uniq
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
        formula = Formula[name]
        return {} unless formula
        formula_inspector formula.to_hash
      end
    end

    def formulae_info
      require "formula"
      Formula.installed.map { |f| formula_inspector f.to_hash }
    end

    def formula_inspector(f)
      installed = f["installed"]
      if f["linked_keg"].nil?
        keg = installed.last
      else
        keg = installed.detect { |k| f["linked_keg"] == k["version"] }
      end

      if keg
        args = keg["used_options"].to_a.map { |option| option.gsub(/^--/, "") }
        args << "HEAD" if keg["version"].to_s.start_with?("HEAD")
        args << "devel" if keg["version"].to_s.gsub(/_\d+$/, "") == f["versions"]["devel"]
        args.uniq!
        version = keg["version"]
      else
        args = []
        version = nil
      end

      {
        name: f["name"],
        oldname: f["oldname"],
        full_name: f["full_name"],
        aliases: f["aliases"],
        args: args,
        version: version,
        dependencies: f["dependencies"],
        recommended_dependencies: f["recommended_dependencies"],
        optional_dependencies: f["optional_dependencies"],
        build_dependencies: f["build_dependencies"],
        requirements: f["requirements"],
        conflicts_with: f["conflicts_with"],
        pinned?: !f["pinned"].nil?,
        outdated?: !f["outdated"].nil?,
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
          ff = @formulae.detect { |formula| formula[:name] == dep || formula[:full_name] == dep }
          ff[:full_name] if ff
        end.compact
      end
      @formulae = topo.tsort.map { |name| @formulae.detect { |formula| formula[:full_name] == name } }
    rescue TSort::Cyclic => e
      odie <<-EOS.undent
        #{e.message}
        Formulae dependency graph sorting failed (likely due to a circular dependency)!
      EOS
    end
  end
end
