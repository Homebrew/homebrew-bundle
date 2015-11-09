require "json"
require "tsort"

module Bundle
  class BrewDumper
    def self.reset!
      @formulae = nil
      @formula_aliases = nil
    end

    def self.formulae
      return @formulae if @formulae
      if Bundle.brew_installed?
        @formulae = formulae_info
        sort!
      else
        raise "Unable to list installed formulae. Homebrew is not currently installed on your system."
      end
      @formulae
    end

    def self.dump
      formulae.map do |f|
        if f[:args].empty?
          "brew '#{f[:full_name]}'"
        else
          args = f[:args].map { |arg| "'#{arg}'" }.join(", ")
          "brew '#{f[:full_name]}', args: [#{args}]"
        end
      end.join("\n")
    end

    def self.cask_requirements
      formulae.map { |f| f[:requirements].map { |req| req["cask"] } }.flatten.compact.uniq
    end

    def self.formula_names
      formulae.map { |f| f[:name] }
    end

    def self.formula_aliases
      return @formula_aliases if @formula_aliases
      @formula_aliases = {}
      formulae.each do |f|
        aliases = f[:aliases]
        next if !aliases || aliases.empty?
        if f[:full_name].include? "/" # tap formula
          aliases.each do |a|
            @formula_aliases[a] = f[:full_name]
            @formula_aliases["#{f[:full_name].rpartition("/").first}/#{a}"] = f[:full_name]
          end
        else
          aliases.each { |a| @formula_aliases[a] = f[:full_name] }
        end
      end
      @formula_aliases
    end

    private

    def self.formulae_info
      begin
        installed_formulae = JSON.load(`brew info --json=v1 --installed`) || []
        installed_formulae.map { |info| formula_inspector info }
      rescue JSON::ParserError
        []
      end
    end

    def self.formula_inspector(f)
      installed = f["installed"]
      if f["linked_keg"].nil?
        keg = installed[-1]
      else
        keg = installed.detect { |k| f["linked_keg"] == k["version"] }
      end
      keg ||= {}
      args = keg["used_options"].map { |option| option.gsub(/^--/, "") }
      args << "HEAD" if keg["version"] == "HEAD"
      args << "devel" if keg["version"].gsub(/_\d+$/, "") == f["versions"]["devel"]
      args.uniq!
      {
        :name => f["name"],
        :full_name => f["full_name"],
        :aliases => f["aliases"],
        :args => args,
        :version => keg["version"],
        :dependencies => f["dependencies"],
        :requirements => f["requirements"],
      }
    end

    class Topo < Hash
      include TSort
      alias_method :tsort_each_node, :each_key
      def tsort_each_child(node, &block)
        fetch(node).each(&block)
      end
    end

    def self.sort!
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
        deps = (f[:dependencies] + f[:requirements].map { |req| req["default_formula"] }.compact).uniq
        topo[f[:full_name]] = deps.map do |dep|
          ff = @formulae.detect { |formula| formula[:name] == dep || formula[:full_name] == dep }
          ff[:full_name] if ff
        end.compact
      end
      @formulae = topo.tsort.map { |name| @formulae.detect { |formula| formula[:full_name] == name } }
    end
  end
end
