# frozen_string_literal: true

require "exceptions"
require "extend/ENV"
require "utils"

module Bundle
  module Commands
    module Exec
      module_function

      def run(*args, global: false, file: nil)
        # Setup Homebrew's ENV extensions
        ENV.activate_extensions!
        raise UsageError, "No command to execute was specified!" if args.blank?

        command = args.first

        # For commands which aren't either absolute or relative
        if command.exclude? "/"
          # Save the command path, since this will be blown away by superenv
          command_path = which(command)
          raise "command was not found in your PATH: #{command}" if command_path.blank?

          command_path = command_path.dirname.to_s
        end

        @dsl = Brewfile.read(global:, file:)

        require "formula"
        require "formulary"

        ENV.deps = @dsl.entries.filter_map do |entry|
          next if entry.type != :brew

          Formulary.factory(entry.name)
        end

        # Allow setting all dependencies to be keg-only
        # (i.e. should be explicitly in HOMEBREW_*PATHs ahead of HOMEBREW_PREFIX)
        ENV.keg_only_deps = if ENV["HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS"].present?
          ENV.delete("HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS")
          ENV.deps
        else
          ENV.deps.select(&:keg_only?)
        end
        ENV.setup_build_environment

        # Enable compiler flag filtering
        ENV.refurbish_args

        # Set up `nodenv`, `pyenv` and `rbenv` if present.
        env_formulae = %w[nodenv pyenv rbenv]
        ENV.deps.each do |dep|
          dep_name = dep.name
          next unless env_formulae.include?(dep_name)

          dep_root = ENV.fetch("HOMEBREW_#{dep_name.upcase}_ROOT", "#{Dir.home}/.#{dep_name}")
          ENV.prepend_path "PATH", Pathname.new(dep_root)/"shims"
        end

        # Setup pkg-config, if present, to help locate packages
        pkgconfig = Formulary.factory("pkg-config")
        ENV.prepend_path "PATH", pkgconfig.opt_bin.to_s if pkgconfig.any_version_installed?

        # Ensure the Ruby path we saved goes before anything else, if the command was in the PATH
        ENV.prepend_path "PATH", command_path if command_path.present?

        # Replace the formula versions from the environment variables
        formula_versions = {}
        ENV.each do |key, value|
          match = key.match(/^HOMEBREW_BUNDLE_EXEC_FORMULA_VERSION_(.+)$/)
          next if match.blank?

          formula_name = match[1]
          next if formula_name.blank?

          ENV.delete(key)
          formula_versions[formula_name.downcase] = value
        end
        formula_versions.each do |formula_name, formula_version|
          ENV.each do |key, value|
            opt = %r{/opt/#{formula_name}([/:$])}
            next unless value.match(opt)

            ENV[key] = value.gsub(opt, "/Cellar/#{formula_name}/#{formula_version}\\1")
          end
        end

        exec(*args)
      end
    end
  end
end
