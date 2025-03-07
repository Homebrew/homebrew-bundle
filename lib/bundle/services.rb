# typed: strict
# frozen_string_literal: true

# TODO: avoid this or use it with https://github.com/Homebrew/brew/pulls
require "formula"
require_relative "../../../homebrew-services/lib/service"

module Bundle
  module Services
    sig { params(entries: T::Array[Bundle::Dsl::Entry]).void }
    def self.start(entries)
      # TODO: refactor
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
          if Service::System.launchctl?
            prefix/"#{formula.plist_name}.plist"
          else
            prefix/"#{formula.sercice_name}.service"
          end
        end

        unless service_file&.file?
          prefix = formula.latest_installed_prefix
          service_file = if Service::System.launchctl?
            prefix/"#{formula.plist_name}.plist"
          else
            prefix/"#{formula.sercice_name}.service"
          end
        end

        p formula.name

        next unless service_file.file?

        p formula.name
        Service::ServicesCli.start([Service::FormulaWrapper.new(formula)], service_file)
      end
    end
  end
end
