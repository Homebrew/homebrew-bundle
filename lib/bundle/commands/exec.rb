require "extend/ENV"
require "formula"
require "utils"

module Bundle
  module Commands
    module Exec
      module_function

      def run
        args = []
        ARGV.each_with_index do |arg, i|
          if arg == "--"
            args = ARGV.slice!(i+1..-1)
            break
          elsif !arg.start_with?("-")
            args = ARGV.slice!(i..-1)
            break
          end
        end

        # Setup Homebrew's ENV extensions
        ENV.activate_extensions!
        raise "No command to execute was specified!" if args.empty?

        command = args[0]

        # Save the command path, since this will be blown away by superenv
        command_path = which(command)
        raise "Error: #{command} was not found on your PATH!" if command_path.nil?
        command_path = command_path.dirname.to_s

        brewfile = Bundle::Dsl.new(Bundle.brewfile)
        ENV.deps = brewfile.entries.map do |entry|
          next unless entry.type == :brew
          f = Formulary.factory(entry.name)
          [f, f.recursive_dependencies.map(&:to_formula)]
        end.flatten.compact
        ENV.keg_only_deps = ENV.deps.select(&:keg_only?)
        ENV.setup_build_environment

        # Enable compiler flag filtering
        ENV.refurbish_args

        # Setup pkg-config, if present, to help locate packages
        pkgconfig = Formulary.factory("pkg-config")
        ENV.prepend_path "PATH", pkgconfig.opt_bin.to_s if pkgconfig.installed?

        # Ensure the Ruby path we saved goes before anything else
        ENV.prepend_path "PATH", command_path

        exec *args
      end
    end
  end
end
