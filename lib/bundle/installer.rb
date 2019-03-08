# frozen_string_literal: true

module Bundle
  module Installer
    module_function

    def install(entries)
      success = 0
      failure = 0
      errored_entries = {}

      entries.each do |entry|
        arg = [entry.name]
        verb = "Installing"
        cls = case entry.type
        when :brew
          arg << entry.options
          Bundle::BrewInstaller
        when :cask
          arg << entry.options
          Bundle::CaskInstaller
        when :mac_app_store
          arg << entry.options[:id]
          Bundle::MacAppStoreInstaller
        when :tap
          verb = "Tapping"
          arg << entry.options
          Bundle::TapInstaller
        end
        begin
          case cls.install(*arg)
          when :success
            puts Formatter.success("#{verb} #{entry.name}")
            success += 1
          when :skipped
            puts "Using #{entry.name}"
            success += 1
          else
            puts Formatter.error("#{verb} #{entry.name} has failed!")
            failure += 1
          end
        rescue => e
          puts Formatter.error("#{verb} #{entry.name} errored: #{e}")
          errored_entries[entry.name] = e
        end
      end

      if failure.zero?
        puts Formatter.success("Homebrew Bundle complete! #{success} Brewfile #{Bundle::Dsl.pluralize_dependency(success)} now installed.")
      else
        puts Formatter.error("Homebrew Bundle failed! #{failure} Brewfile #{Bundle::Dsl.pluralize_dependency(failure)} failed to install.")
      end

      unless errored_entries.empty?
        puts Formatter.error("Homebrew Bundle encountered some errors! #{errored_entries.size} Brewfile #{Bundle::Dsl.pluralize_dependency(errored_entries.size)} failed badly:")
        errored_entries.each do |entry, error|
          puts Formatter.error("\t#{entry}\t => \t#{error}")
        end
      end

      failure.zero? && errored_entries.empty?
    end
  end
end
