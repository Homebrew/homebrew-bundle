# frozen_string_literal: true

module Bundle
  module Installer
    module_function

    def install(entries, global: false, file: nil, no_lock: false, no_upgrade: false, verbose: false)
      success = 0
      failure = 0

      entries.each do |entry|
        name = entry.name
        args = [name]
        options = {}
        verb = "Installing"
        type = entry.type
        cls = case type
        when :brew
          options = entry.options
          verb = "Upgrading" if Bundle::BrewInstaller.formula_upgradable?(name)
          Bundle::BrewInstaller
        when :cask
          options = entry.options
          verb = "Upgrading" if Bundle::CaskInstaller.cask_upgradable?(name)
          Bundle::CaskInstaller
        when :mas
          args << entry.options[:id]
          Bundle::MacAppStoreInstaller
        when :whalebrew
          Bundle::WhalebrewInstaller
        when :vscode
          Bundle::VscodeExtensionInstaller
        when :tap
          verb = "Tapping"
          options = entry.options
          Bundle::TapInstaller
        end

        next if Bundle::Skipper.skip? entry

        preinstall = if cls.preinstall(*args, **options, no_upgrade: no_upgrade, verbose: verbose)
          # XXX: no method in Library/Homebrew/extend/kernel.rb wrapping Formatter.success simply, just pretty_installed(Formula)
          puts Formatter.success("#{verb} #{name}")
          true
        else
          ohai "Using #{name}"
          false
        end

        if cls.install(*args, **options, preinstall: preinstall, no_upgrade: no_upgrade, verbose: verbose)
          success += 1
        else
          onoe "#{verb} #{name} has failed!"
          failure += 1
        end
      end

      unless failure.zero?
        ofail "Homebrew Bundle failed! " \
                             "#{failure} Brewfile #{Bundle::Dsl.pluralize_dependency(failure)} failed to install."
        if (lock = Bundle::Locker.lockfile(global: global, file: file)) && lock.exist?
          ofail "Check for differences in your #{lock.basename}!"
        end
        return false
      end

      Bundle::Locker.lock(entries, global: global, file: file, no_lock: no_lock)

      # XXX: no method in Library/Homebrew/extend/kernel.rb wrapping Formatter.success simply, just pretty_installed(Formula)
      puts Formatter.success "Homebrew Bundle complete! " \
                             "#{success} Brewfile #{Bundle::Dsl.pluralize_dependency(success)} now installed."
      true
    end
  end
end
