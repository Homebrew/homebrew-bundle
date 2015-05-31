require "json"

module Bundle
  class BrewDumper
    attr_reader :formulae

    def initialize
      if Bundle.brew_installed?
        formulae_info = JSON.load(`brew info --json=v1 --installed`) || [] rescue []
        @formulae = formulae_info.map { |info| formula_inspector info }
      else
        raise "Unable to list installed formulae. Homebrew is not currently installed on your system."
      end
    end

    def to_s
      @formulae.map do |f|
        if f[:args].empty?
          "brew '#{f[:full_name]}'"
        else
          args = f[:args].map { |arg| "'#{arg}'" }.join(", ")
          "brew '#{f[:full_name]}', args: [#{args}]"
        end
      end.join("\n")
    end

    private

    def formula_inspector f
      installed = f["installed"]
      if f["linked_keg"].nil?
        keg = installed[-1]
      else
        keg = installed.detect { |k| f["linked_keg"] == k["version"] }
      end
      args = keg["used_options"].map { |option| option.gsub(/^--/, "") }
      args << "HEAD" if keg["version"] == "HEAD"
      args << "devel" if keg["version"].gsub(/_\d+$/, "") == f["versions"]["devel"]
      args.uniq!
      {name: f["name"], full_name: f["full_name"], args: args, version: keg["version"]}
    end
  end
end
