# frozen_string_literal: true

module Bundle
  module Installer
    module_function

    def install(entries)
      success = 0
      failure = 0

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

        next if Bundle::Bouncer.refused? entry

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
      end

      if failure.zero?
        puts Formatter.success("Homebrew Bundle complete! #{success} Brewfile #{Bundle::Dsl.pluralize_dependency(success)} now installed.")
      else
        puts Formatter.error("Homebrew Bundle failed! #{failure} Brewfile #{Bundle::Dsl.pluralize_dependency(failure)} failed to install.")
      end

      failure.zero?
    end
  end
end
