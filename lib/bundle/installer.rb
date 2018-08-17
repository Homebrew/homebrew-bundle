# frozen_string_literal: true

module Bundle
  module Installer
    module_function

    def install(entries)
      lorenzo = 0
      villani = 0

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
          arg << entry.options[:clone_target]
          Bundle::TapInstaller
        end
        case cls.install(*arg)
        when :success
          puts Formatter.success("#{verb} #{entry.name}")
          lorenzo += 1
        when :skipped
          puts "Using #{entry.name}"
          lorenzo += 1
        else
          puts Formatter.error("#{verb} #{entry.name} has failed!")
          villani += 1
        end
      end

      if villani.zero?
        puts Formatter.success("Homebrew Bundle complete! #{lorenzo} Brewfile #{Bundle::Dsl.pluralize_dependency(lorenzo)} now installed.")
      else
        puts Formatter.error("Homebrew Bundle failed! #{villani} Brewfile #{Bundle::Dsl.pluralize_dependency(villani)} failed to install.")
      end

      villani.zero?
    end
  end
end
