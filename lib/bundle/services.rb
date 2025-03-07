# typed: strict
# frozen_string_literal: true

require "formula"
require "services/cli"
require "services/system"

module Bundle
  module Services
    sig {
      params(
        entries: T::Array[Bundle::Dsl::Entry],
        _block:  T.proc.params(wrapper: Homebrew::Services::FormulaWrapper, service_file: Pathname).void,
      ).void
    }
    private_class_method def self.map_entries(entries, &_block)
      formula_versions = {}
      ENV.each do |key, value|
        match = key.match(/^HOMEBREW_BUNDLE_EXEC_FORMULA_VERSION_(.+)$/)
        next if match.blank?

        formula_name = match[1]
        next if formula_name.blank?

        ENV.delete(key)
        formula_versions[formula_name.downcase] = value
      end

      entries.filter_map do |entry|
        next if entry.type != :brew

        formula = Formula[entry.name]
        next unless formula.any_version_installed?

        version = formula_versions[entry.name.downcase]
        prefix = formula.rack/version if version

        service_file = if prefix&.directory?
          if Homebrew::Services::System.launchctl?
            prefix/"#{formula.plist_name}.plist"
          else
            prefix/"#{formula.service_name}.service"
          end
        end

        unless service_file&.file?
          prefix = formula.any_installed_prefix
          next if prefix.nil?

          service_file = if Homebrew::Services::System.launchctl?
            prefix/"#{formula.plist_name}.plist"
          else
            prefix/"#{formula.service_name}.service"
          end
        end

        next unless service_file.file?

        wrapper = Homebrew::Services::FormulaWrapper.new(formula)

        yield wrapper, service_file
      end
    end

    sig { params(entries: T::Array[Bundle::Dsl::Entry]).void }
    def self.run(entries)
      map_entries(entries) do |wrapper, service_file|
        next if wrapper.pid? # already started

        if Homebrew::Services::System.launchctl?
          Homebrew::Services::Cli.launchctl_load(wrapper, file: service_file, enable: false)
        elsif Homebrew::Services::System.systemctl?
          Homebrew::Services::Cli.install_service_file(wrapper, service_file)
          Homebrew::Services::Cli.systemd_load(wrapper, enable: false)
        end

        ohai "Running service `#{wrapper.name}` (label: #{wrapper.service_name})"
      end
    end

    sig { params(entries: T::Array[Bundle::Dsl::Entry]).void }
    def self.stop(entries)
      map_entries(entries) do |wrapper, _service_file|
        next unless wrapper.loaded?

        # Try avoid services not started by `brew bundle services`
        next if Homebrew::Services::System.launchctl? && wrapper.dest.exist?

        Homebrew::Services::Cli.stop([wrapper])
      end
    end
  end
end
