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
        when :mas
          arg << entry.options[:id]
          Bundle::MacAppStoreInstaller
        when :whalebrew
          Bundle::WhalebrewInstaller
        when :tap
          verb = "Tapping"
          arg << entry.options
          Bundle::TapInstaller
        end

        next if Bundle::Skipper.skip? entry

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

      unless failure.zero?
        puts Formatter.error("Homebrew Bundle failed! #{failure} Brewfile #{Bundle::Dsl.pluralize_dependency(failure)} failed to install.")
        if (lock = Bundle::Locker.lockfile) && lock.exist?
          puts Formatter.error("Check for differences in your #{lock.basename}!")
        end
        return false
      end

      Bundle::Locker.lock(entries)

      puts Formatter.success("Homebrew Bundle complete! #{success} Brewfile #{Bundle::Dsl.pluralize_dependency(success)} now installed.")
      true
    end
  end
end
